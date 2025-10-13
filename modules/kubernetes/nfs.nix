{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.k3s-cluster.storage;
in
{
  options.services.k3s-cluster.storage = {
    server = {
      enable = mkEnableOption "K3s storage server (SFTP)";

      storageDir = mkOption {
        type = types.str;
        default = "/mnt/k3s-storage";
        description = "Root directory for K3s storage";
      };

      sshUser = mkOption {
        type = types.str;
        default = "k3s-storage";
        description = "Dedicated SSH user for storage access";
      };

      authorizedKeys = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "SSH public keys authorized for storage access";
      };
    };

    client = {
      enable = mkEnableOption "K3s storage client (SSHFS mount)";

      serverAddress = mkOption {
        type = types.str;
        example = "neptune.local";
        description = "Storage server hostname or IP";
      };

      serverUser = mkOption {
        type = types.str;
        default = "k3s-storage";
        description = "SSH user on storage server";
      };

      remoteDir = mkOption {
        type = types.str;
        default = "/mnt/k3s-storage";
        description = "Remote directory path on storage server";
      };

      mountPoint = mkOption {
        type = types.str;
        default = "/mnt/k3s-storage";
        description = "Local mount point";
      };

      sshKeyFile = mkOption {
        type = types.path;
        description = "Path to SSH private key (managed by sops)";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.server.enable {
      users.users.${cfg.server.sshUser} = {
        isNormalUser = true;
        home = cfg.server.storageDir;
        createHome = false;
        group = cfg.server.sshUser;
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keys = cfg.server.authorizedKeys;
      };

      users.groups.${cfg.server.sshUser} = { };

      systemd.tmpfiles.rules = [
        "d ${cfg.server.storageDir} 0755 ${cfg.server.sshUser} ${cfg.server.sshUser} -"
      ];

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "yes";
        };
      };

      environment.systemPackages = [ pkgs.openssh ];
    })

    (mkIf cfg.client.enable {
      environment.systemPackages = [ pkgs.sshfs ];

      systemd.tmpfiles.rules = [
        "d ${cfg.client.mountPoint} 0755 root root -"
      ];

      fileSystems."${cfg.client.mountPoint}" = {
        device = "${cfg.client.serverUser}@${cfg.client.serverAddress}:${cfg.client.remoteDir}";
        fsType = "sshfs";
        options = [
          "nodev"
          "noatime"
          "allow_other"
          "IdentityFile=${cfg.client.sshKeyFile}"
          "StrictHostKeyChecking=accept-new"
          "ServerAliveInterval=60"
          "ServerAliveCountMax=3"
          "reconnect"
          "x-systemd.automount"
          "_netdev"
          "x-systemd.mount-timeout=30s"
        ];
      };
    })
  ];
}
