# modules/kubernetes/base.nix
# Gemeinsame Kubernetes-Basis für alle Cluster-Nodes
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.k8s-cluster;
  
  # Aktiviert wenn Master ODER Worker enabled ist
  isEnabled = cfg.master.enable or false || cfg.worker.enable or false;
in
{
  options.services.k8s-cluster = {
    # ════════════════════════════════════════════════════════════════════════
    # SHARED OPTIONS (von Master UND Worker genutzt)
    # ════════════════════════════════════════════════════════════════════════
    
    masterAddress = mkOption {
      type = types.str;
      example = "192.168.2.33";
      description = "IP-Adresse des Master Nodes";
    };

    clusterName = mkOption {
      type = types.str;
      default = "homelab";
      description = "Name des Kubernetes Clusters";
    };

    clusterCidr = mkOption {
      type = types.str;
      default = "10.244.0.0/16";
      description = "Pod Network CIDR (Flannel Default)";
    };

    serviceCidr = mkOption {
      type = types.str;
      default = "10.96.0.0/12";
      description = "Service Network CIDR";
    };

    clusterDns = mkOption {
      type = types.str;
      default = "10.96.0.10";
      description = "DNS Service IP (muss in serviceCidr liegen)";
    };
    easyCerts = mkOption {
      type = types.bool;
      default = true;
      description = "Automatisches Certificate Bootstrapping aktivieren";
    };
  };

  config = mkIf isEnabled {
    # ════════════════════════════════════════════════════════════════════════
    # KUBERNETES BASE CONFIGURATION
    # ════════════════════════════════════════════════════════════════════════
    services.kubernetes = {
      # Cluster-Identifikation (MANDATORY seit NixOS 19.03)
      masterAddress = cfg.masterAddress;
      clusterCidr = cfg.clusterCidr;

      # KORREKTUR: easyCerts für automatisches Zertifikat-Management
      easyCerts = cfg.easyCerts;

      # Flannel CNI (VXLAN Overlay Network)
      flannel.enable = true;

      # KORREKTUR: PKI mit easyCerts
      pki = mkIf cfg.easyCerts {
        enable = true;
        etcClusterAdminKubeconfig = "kubernetes/cluster-admin.kubeconfig";
      };

      # KORREKTUR: DNS Addon nur auf Master, korrekter Path
      addons.dns = mkIf cfg.master.enable {
        enable = true;
        clusterIp = cfg.clusterDns;
      };
    };

    # ════════════════════════════════════════════════════════════════════════
    # ASSERTIONS & VALIDATIONS
    # ════════════════════════════════════════════════════════════════════════
    assertions = [
      {
        assertion = cfg.masterAddress != "";
        message = "services.k8s-cluster.masterAddress ist mandatory seit NixOS 19.03";
      }
      {
        assertion = cfg.clusterDns != "" && hasPrefix "10.96." cfg.clusterDns;
        message = "clusterDns muss in serviceCidr (${cfg.serviceCidr}) liegen";
      }
    ];

    # ════════════════════════════════════════════════════════════════════════
    # NETZWERK & FIREWALL (Basis für alle Nodes)
    # ════════════════════════════════════════════════════════════════════════
    networking.firewall = {
      enable = true;
      # Flannel VXLAN
      allowedUDPPorts = [ 8472 ];
      # Flannel Interface vertrauen
      trustedInterfaces = [ "flannel.1" ];
    };

    # ════════════════════════════════════════════════════════════════════════
    # SYSTEM PACKAGES (für alle Nodes)
    # ════════════════════════════════════════════════════════════════════════
    environment.systemPackages = with pkgs; [
      kubectl
      kubernetes-helm
    ];

    # ════════════════════════════════════════════════════════════════════════
    # KUBECONFIG Environment Variable (nur mit easyCerts)
    # ════════════════════════════════════════════════════════════════════════
    environment.variables = mkIf cfg.easyCerts {
      KUBECONFIG = "/etc/${config.services.kubernetes.pki.etcClusterAdminKubeconfig}";
    };

    # KORREKTUR: Warning für Multi-Master HA
    warnings = mkIf (cfg.easyCerts && cfg.master.enable) [
      "easyCerts unterstützt keine Multi-Master (HA) Clusters. Für Production sollten externe Zertifikate verwendet werden."
    ];
  };
}