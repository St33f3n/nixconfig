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

    nodeLabels = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "node-role=master" "gpu=true" ];
      description = "Node labels in key=value format";
    };

    nodeTaints = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "node-role=master:NoSchedule" ];
      description = "Node taints in key=value:effect format";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional K3s server flags";
    };

    tls = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Deploy TLS certificates to Kubernetes secrets";
      };

      localCertFile = mkOption {
        type = types.path;
        default = config.sops.secrets.local_tls_cert.path;
        description = "Path to local certificate secret (base64 encoded)";
      };

      localKeyFile = mkOption {
        type = types.path;
        default = config.sops.secrets.local_tls_key.path;
        description = "Path to local key secret (base64 encoded)";
      };

      publicCertFile = mkOption {
        type = types.path;
        default = config.sops.secrets.public_tls_cert.path;
        description = "Path to public certificate secret (base64 encoded)";
      };

      publicKeyFile = mkOption {
        type = types.path;
        default = config.sops.secrets.public_tls_key.path;
        description = "Path to public key secret (base64 encoded)";
      };
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
        ]
        ++ (map (label: "--node-label=${label}") cfg.nodeLabels)
        ++ (map (taint: "--node-taint=${taint}") cfg.nodeTaints)
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

  # TLS Certificate Deployment
    systemd.services.k3s-deploy-tls-certs = mkIf cfg.tls.enable {
      description = "Deploy TLS certificates to K3s";
      after = [ "k3s.service" ];
      requires = [ "k3s.service" ];
      wantedBy = [ "multi-user.target" ];
      
      environment = {
        KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      };
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "30s";
      };
      
      preStart = "${pkgs.coreutils}/bin/sleep 10";
      
      script = ''
        set -euo pipefail
        
        TMPDIR=$(${pkgs.coreutils}/bin/mktemp -d)
        trap "${pkgs.coreutils}/bin/rm -rf $TMPDIR" EXIT
        
        echo "Deploying local TLS certificate..."
        ${pkgs.coreutils}/bin/cat ${cfg.tls.localCertFile} | ${pkgs.coreutils}/bin/base64 -d > "$TMPDIR/local.crt"
        ${pkgs.coreutils}/bin/cat ${cfg.tls.localKeyFile} | ${pkgs.coreutils}/bin/base64 -d > "$TMPDIR/local.key"
        
        ${pkgs.kubectl}/bin/kubectl create secret tls local-tls-cert \
          --cert="$TMPDIR/local.crt" \
          --key="$TMPDIR/local.key" \
          --namespace=kube-system \
          --dry-run=client -o yaml | ${pkgs.kubectl}/bin/kubectl apply -f -
        
        echo "Deploying public TLS certificate..."
        ${pkgs.coreutils}/bin/cat ${cfg.tls.publicCertFile} | ${pkgs.coreutils}/bin/base64 -d > "$TMPDIR/public.crt"
        ${pkgs.coreutils}/bin/cat ${cfg.tls.publicKeyFile} | ${pkgs.coreutils}/bin/base64 -d > "$TMPDIR/public.key"
        
        ${pkgs.kubectl}/bin/kubectl create secret tls public-tls-cert \
          --cert="$TMPDIR/public.crt" \
          --key="$TMPDIR/public.key" \
          --namespace=kube-system \
          --dry-run=client -o yaml | ${pkgs.kubectl}/bin/kubectl apply -f -
        
        echo "TLS certificates deployed successfully"
      '';
    };

  
  };
}
