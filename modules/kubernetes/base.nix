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
  isEnabled = cfg.master.enable || cfg.worker.enable;
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

    # Placeholder-Optionen für Master/Worker (werden in Submodulen definiert)
    master = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Master-spezifische Konfiguration";
    };

    worker = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Worker-spezifische Konfiguration";
    };
  };

  config = mkIf isEnabled {
    # ════════════════════════════════════════════════════════════════════════
    # KUBERNETES BASE CONFIGURATION
    # ════════════════════════════════════════════════════════════════════════
    services.kubernetes = {
      # Cluster-Identifikation
      masterAddress = cfg.masterAddress;
      clusterCidr = cfg.clusterCidr;

      # Flannel CNI (VXLAN Overlay Network)
      flannel.enable = true;

      # PKI-Pfade (NixOS-Standard)
      pki = {
        enable = true;
        etcClusterAdminKubeconfig = "kubernetes/cluster-admin.kubeconfig";
      };

      # Addon: CoreDNS (nur auf Master, aber Option hier für Konsistenz)
      addons.dns = {
        enable = cfg.master.enable;
        clusterIp = cfg.clusterDns;
      };
    };

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
    # KUBECONFIG Environment Variable
    # ════════════════════════════════════════════════════════════════════════
    environment.variables = {
      KUBECONFIG = "/etc/${config.services.kubernetes.pki.etcClusterAdminKubeconfig}";
    };
  };
}