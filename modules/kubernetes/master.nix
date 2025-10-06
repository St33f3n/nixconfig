# kubernetes/master.nix - Master Node Configuration
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
  config = mkIf (cfg.enable && cfg.role == "master") {

    # ══════════════════════════════════════════════════════════════════════
    # KUBERNETES MASTER COMPONENTS
    # ══════════════════════════════════════════════════════════════════════
    services.kubernetes = {
      roles = [ "master" ];

      # ────────────────────────────────────────────────────────────────────
      # API Server
      # ────────────────────────────────────────────────────────────────────
      apiserver = {
        # Externe Erreichbarkeit
        advertiseAddress = cfg.masterAddress;
        bindAddress = "0.0.0.0";
        
        # Secure Port
        securePort = 6443;
        
        # Service Account Key (automatisch via easyCerts)
        serviceAccountKeyFile = mkDefault null;
        
        # Additional API Server Options
        extraOpts = "--allow-privileged=true";
      };

      # ────────────────────────────────────────────────────────────────────
      # Controller Manager
      # ────────────────────────────────────────────────────────────────────
      controllerManager = {
        enable = true;
        # Cluster CIDR für Pod IPs
        clusterCidr = cfg.clusterCidr;
      };

      # ────────────────────────────────────────────────────────────────────
      # Scheduler
      # ────────────────────────────────────────────────────────────────────
      scheduler = {
        enable = true;
      };

      # ────────────────────────────────────────────────────────────────────
      # etcd
      # ────────────────────────────────────────────────────────────────────
      etcd = {
        enable = true;
        # Listen auf allen Interfaces für Cluster-Members
        listenClientUrls = [ "https://0.0.0.0:2379" ];
        advertiseClientUrls = [ "https://${cfg.masterAddress}:2379" ];
        
        # Peer communication (für Multi-Master später)
        listenPeerUrls = [ "https://0.0.0.0:2380" ];
        initialAdvertisePeerUrls = [ "https://${cfg.masterAddress}:2380" ];
      };

      # ────────────────────────────────────────────────────────────────────
      # Kubelet (auch auf Master für System-Pods)
      # ────────────────────────────────────────────────────────────────────
      kubelet = {
        enable = true;
        # Master soll auch Pods schedulen können (für kleine Cluster)
        # Für Produktion: Master sollte nur Control Plane Pods haben
        taints = {
          # Kommentiere diese Zeile aus, wenn Master keine Workload-Pods haben soll:
          # "node-role.kubernetes.io/master" = "NoSchedule";
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
    # ADDON DEPLOYMENTS (via static manifests)
    # ══════════════════════════════════════════════════════════════════════
    
    # CoreDNS manifest (wird automatisch geladen)
    services.kubernetes.addonManager.enable = true;
    
    # ──────────────────────────────────────────────────────────────────────
    # Metrics Server (für kubectl top)
    # ──────────────────────────────────────────────────────────────────────
    environment.etc."kubernetes/addons/metrics-server.yaml" = mkIf cfg.enable {
      text = ''
        apiVersion: v1
        kind: ServiceAccount
        metadata:
          name: metrics-server
          namespace: kube-system
        ---
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: metrics-server
          namespace: kube-system
        spec:
          selector:
            matchLabels:
              k8s-app: metrics-server
          template:
            metadata:
              labels:
                k8s-app: metrics-server
            spec:
              serviceAccountName: metrics-server
              containers:
              - name: metrics-server
                image: registry.k8s.io/metrics-server/metrics-server:v0.7.0
                args:
                - --kubelet-insecure-tls
                - --kubelet-preferred-address-types=InternalIP
      '';
    };

    # ══════════════════════════════════════════════════════════════════════
    # HELPER SCRIPTS
    # ══════════════════════════════════════════════════════════════════════
    
    # Script zum Generieren des Worker-Join-Tokens
    environment.systemPackages = with pkgs; [
      (writeScriptBin "k8s-generate-worker-token" ''
        #!${pkgs.bash}/bin/bash
        # Generiert ein Bootstrap-Token für neue Worker-Nodes
        
        TOKEN=$(${kubectl}/bin/kubectl -n kube-system create token default)
        CA_HASH=$(openssl x509 -pubkey -in /var/lib/kubernetes/secrets/ca.pem | \
                  openssl rsa -pubin -outform der 2>/dev/null | \
                  openssl dgst -sha256 -hex | sed 's/^.* //')
        
        echo "=== Worker Join Command ==="
        echo "Use this in your worker node secrets/k8s.yaml:"
        echo ""
        echo "k8s_token: $TOKEN"
        echo "k8s_ca_hash: sha256:$CA_HASH"
        echo ""
        echo "Master: ${cfg.masterAddress}:6443"
      '')
    ];
  };
}