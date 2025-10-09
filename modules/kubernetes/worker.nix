{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.k3s-cluster.agent;
in
{
  options.services.k3s-cluster.agent = {
    enable = mkEnableOption "K3s Agent (Worker Node)";

    serverAddress = mkOption {
      type = types.str;
      example = "https://192.168.2.56:6443";
      description = "K3s server URL (must include https:// and :6443)";
    };

    tokenFile = mkOption {
      type = types.path;
      description = "Path to file containing cluster join token";
    };

    nodeAddress = mkOption {
      type = types.str;
      example = "192.168.2.57";
      description = "IP address of this agent node";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional K3s agent flags";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.services.k3s-cluster.server.enable;
        message = "K3s server and agent cannot run on the same node";
      }
      {
        assertion = hasPrefix "https://" cfg.serverAddress;
        message = "serverAddress must start with https://";
      }
    ];

    services.k3s = {
      enable = true;
      role = "agent";
      serverAddr = cfg.serverAddress;
      inherit (cfg) tokenFile;

      extraFlags = lib.concatStringsSep " " (
        [
          "--node-ip=${cfg.nodeAddress}"
        ]
        ++ cfg.extraFlags
      );
    };

    environment.systemPackages = with pkgs; [
      k3s
      kubectl
    ];

    networking.firewall = {
      allowedTCPPorts = [ 10250 ];
      allowedUDPPorts = [ 8472 ];
      trustedInterfaces = [ "flannel.1" ];
    };

  };
}
