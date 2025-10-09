{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.k3s-cluster.server;
in
{
  options.services.k3s-cluster.server = {
    enable = mkEnableOption "K3s Server (Master Node)";

    nodeAddress = mkOption {
      type = types.str;
      example = "192.168.2.56";
      description = "IP address of this server node";
    };

    tokenFile = mkOption {
      type = types.path;
      description = "Path to file containing cluster join token";
    };

    kubeconfigPath = mkOption {
      type = types.str;
      default = "/home/biocirc/.config/k3s/kubeconfig";
      description = "Where to write kubeconfig with user permissions";
    };

    clusterCidr = mkOption {
      type = types.str;
      default = "10.42.0.0/16";
      description = "Pod network CIDR (Flannel default)";
    };

    serviceCidr = mkOption {
      type = types.str;
      default = "10.43.0.0/16";
      description = "Service network CIDR";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional K3s server flags";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.services.k3s-cluster.agent.enable;
        message = "K3s server and agent cannot run on the same node";
      }
    ];

    services.k3s = {
      enable = true;
      role = "server";
      inherit (cfg) tokenFile;

      extraFlags = lib.concatStringsSep " " (
        [
          "--node-ip=${cfg.nodeAddress}"
          "--cluster-cidr=${cfg.clusterCidr}"
          "--service-cidr=${cfg.serviceCidr}"
          "--write-kubeconfig=${cfg.kubeconfigPath}"
          "--write-kubeconfig-mode=644"
          "--flannel-backend=vxlan"
          "--disable=traefik"
        ]
        ++ cfg.extraFlags
      );
    };

    systemd.tmpfiles.rules = [
      "d ${dirOf cfg.kubeconfigPath} 0755 biocirc users -"
    ];

    systemd.services.k3s.serviceConfig = {
      ExecStartPost = "${pkgs.coreutils}/bin/chown biocirc:users ${cfg.kubeconfigPath}";
    };

    environment.systemPackages = with pkgs; [
      k3s
      kubectl
      kubernetes-helm
    ];

    environment.variables = {
      KUBECONFIG = cfg.kubeconfigPath;
    };

    networking.firewall = {
      allowedTCPPorts = [
        6443
        10250
      ];
      allowedUDPPorts = [
        8472
      ];
      trustedInterfaces = [ "flannel.1" ];
    };

  };
}
