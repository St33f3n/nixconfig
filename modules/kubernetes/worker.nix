# kubernetes/worker.nix - Worker Node Configuration
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.k8s-cluster;
in
{
  config = mkIf (cfg.enable && cfg.role == "worker") {

    # ══════════════════════════════════════════════════════════════════════
    # KUBERNETES WORKER COMPONENTS
    # ══════════════════════════════════════════════════════════════════════
    services.kubernetes = {
      roles = [ "node" ];

      # ────────────────────────────────────────────────────────────────────
      # Kubelet
      # ────────────────────────────────────────────────────────────────────
      kubelet = {
        enable = true;
        
        # Hostname wird automatisch erkannt
        hostname = config.networking.hostName;
        
        # Labels für node selection (optional)
        nodeLabels = {
          "node-role.kubernetes.io/worker" = "";
          "environment" = "production";  # Anpassbar
        };
        
        # Resource Reservierung für System (optional)
        kubeReserved = {
          cpu = "200m";
          memory = "512Mi";
          ephemeral-storage = "1Gi";
        };
        
        systemReserved = {
          cpu = "200m";
          memory = "512Mi";
          ephemeral-storage = "1Gi";
        };
      };

      # ────────────────────────────────────────────────────────────────────
      # Proxy
      # ────────────────────────────────────────────────────────────────────
      proxy = {
        enable = true;
      };
    };

    # ══════════════════════════════════════════════════════════════════════
    # AUTOMATIC CLUSTER JOIN
    # ══════════════════════════════════════════════════════════════════════
    
    # Worker braucht:
    # 1. Master CA Certificate (via SOPS)
    # 2. Bootstrap Token (via SOPS)
    # 3. Master API Server Address
    
    # Diese werden in secrets/k8s.yaml gespeichert:
    # k8s_token: <bootstrap-token-from-master>
    # k8s_ca_hash: sha256:<ca-cert-hash>
    
    # Automatisches Join erfolgt via easyCerts und masterAddress

    # ══════════════════════════════════════════════════════════════════════
    # WORKER-SPECIFIC FEATURES (optional)
    # ══════════════════════════════════════════════════════════════════════
    
    # GPU Support (wenn vorhanden)
    # services.kubernetes.kubelet.extraOpts = mkIf config.hardware.nvidia.enable 
    #   "--feature-gates=DevicePlugins=true";
    
    # Beispiel: Local Storage für Persistent Volumes
    # fileSystems."/mnt/k8s-storage" = {
    #   device = "/dev/sdb1";
    #   fsType = "ext4";
    # };
  };
}