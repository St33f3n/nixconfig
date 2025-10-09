{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.k3s-cluster.nfs;
in
{
  options.services.k3s-cluster.nfs = {
    server = {
      enable = mkEnableOption "NFS server for K3s storage";

      storageDir = mkOption {
        type = types.str;
        default = "/mnt/k3s-storage";
        description = "Root directory for K3s NFS exports";
      };

      allowedNetworks = mkOption {
        type = types.listOf types.str;
        default = [ "192.168.2.0/24" ];
        description = "Networks allowed to mount NFS shares";
      };
    };

    client = {
      enable = mkEnableOption "NFS client for K3s storage";

      serverAddress = mkOption {
        type = types.str;
        example = "192.168.2.56";
        description = "NFS server IP address";
      };

      mountPoint = mkOption {
        type = types.str;
        default = "/mnt/k3s-storage";
        description = "Local mount point for NFS share";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.server.enable {
      services.nfs.server = {
        enable = true;
        exports = ''
          ${cfg.server.storageDir} ${
            concatStringsSep " " (
              map (net: "${net}(rw,sync,no_subtree_check,no_root_squash)") cfg.server.allowedNetworks
            )
          }
        '';
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.server.storageDir} 0755 root root -"
      ];

      networking.firewall.allowedTCPPorts = [ 2049 ];

      environment.systemPackages = [ pkgs.nfs-utils ];
    })

    (mkIf cfg.client.enable {
      services.rpcbind.enable = true;

      systemd.tmpfiles.rules = [
        "d ${cfg.client.mountPoint} 0755 root root -"
      ];

      fileSystems."${cfg.client.mountPoint}" = {
        device = "${cfg.client.serverAddress}:${cfg.server.storageDir}";
        fsType = "nfs4";
        options = [
          "rw"
          "soft"
          "intr"
          "timeo=30"
          "retrans=2"
        ];
      };

      environment.systemPackages = [ pkgs.nfs-utils ];
    })
  ];
}