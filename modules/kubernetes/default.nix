# kubernetes/default.nix - Shared Kubernetes Configuration
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
  options.services.k8s-cluster = {
    enable = mkEnableOption "Kubernetes cluster (master or worker)";

    # ──────────────────────────────────────────────────────────────────────
    # Role Selection
    # ──────────────────────────────────────────────────────────────────────
    role = mkOption {
      type = types.enum [ "master" "worker" ];
      description = "Node role in the cluster";
    };

    # ──────────────────────────────────────────────────────────────────────
    # Cluster Configuration
    # ──────────────────────────────────────────────────────────────────────
    clusterName = mkOption {
      type = types.str;
      default = "nixos-k8s";
      description = "Kubernetes cluster name";
    };

    masterAddress = mkOption {
      type = types.str;
      example = "192.168.2.50";
      description = "IP address of the master node";
    };

    # ──────────────────────────────────────────────────────────────────────
    # Networking
    # ──────────────────────────────────────────────────────────────────────
    clusterCidr = mkOption {
      type = types.str;
      default = "10.244.0.0/16";
      description = "Pod network CIDR";
    };

    serviceCidr = mkOption {
      type = types.str;
      default = "10.96.0.0/12";
      description = "Service network CIDR";
    };

    # ──────────────────────────────────────────────────────────────────────
    # CNI Plugin
    # ──────────────────────────────────────────────────────────────────────
    cniPlugin = mkOption {
      type = types.enum [ "flannel" "calico" "cilium" ];
      default = "flannel";
      description = "Container Network Interface plugin";
    };

    # ──────────────────────────────────────────────────────────────────────
    # Secrets (via SOPS)
    # ──────────────────────────────────────────────────────────────────────
    # Diese werden über SOPS verschlüsselt in secrets/k8s.yaml gespeichert
    # Beispiel: sops.secrets.k8s-ca-cert = { };
  };

  # ════════════════════════════════════════════════════════════════════════
  # COMMON CONFIGURATION (for both master and worker)
  # ════════════════════════════════════════════════════════════════════════
  config = mkIf cfg.enable {

    # ──────────────────────────────────────────────────────────────────────
    # Base Kubernetes Services
    # ──────────────────────────────────────────────────────────────────────
    services.kubernetes = {
      roles = mkDefault [ ];  # Wird in master.nix/worker.nix überschrieben
      
      masterAddress = cfg.masterAddress;
      clusterCidr = cfg.clusterCidr;
      
      # Flannel als Default CNI (leichtgewichtig, einfach)
      flannel.enable = mkDefault (cfg.cniPlugin == "flannel");
      
      # Easy PKI Setup (NixOS managed)
      easyCerts = true;
      
      # Kubelet Common Settings
      kubelet = {
        extraOpts = "--fail-swap-on=false"; # Allow swap (für Entwicklung)
        seedDockerImages = []; # Keine pre-seeded Images
      };
    };

    # ──────────────────────────────────────────────────────────────────────
    # Networking & Firewall
    # ──────────────────────────────────────────────────────────────────────
    networking.firewall = {
      enable = true;
      
      # Common Kubernetes Ports
      allowedTCPPorts = [
        6443   # API Server
        10250  # Kubelet API
        10251  # kube-scheduler
        10252  # kube-controller-manager
        2379   # etcd client
        2380   # etcd peer
      ];
      
      # Flannel VXLAN
      allowedUDPPorts = mkIf (cfg.cniPlugin == "flannel") [
        8472  # Flannel VXLAN
      ];
      
      # Allow pod-to-pod communication
      trustedInterfaces = [ "cni0" "flannel.1" ];
    };

    # ──────────────────────────────────────────────────────────────────────
    # Container Runtime (containerd)
    # ──────────────────────────────────────────────────────────────────────
    virtualisation.containerd = {
      enable = true;
      settings = {
        version = 2;
        plugins."io.containerd.grpc.v1.cri" = {
          sandbox_image = "registry.k8s.io/pause:3.9";
          containerd.runtimes.runc = {
            runtime_type = "io.containerd.runc.v2";
          };
        };
      };
    };

    # ──────────────────────────────────────────────────────────────────────
    # Essential Tools
    # ──────────────────────────────────────────────────────────────────────
    environment.systemPackages = with pkgs; [
      kubectl
      kubernetes-helm
      k9s  # Terminal UI for Kubernetes
      stern  # Multi-pod log tailing
    ];

    # ──────────────────────────────────────────────────────────────────────
    # System Tunables für Kubernetes
    # ──────────────────────────────────────────────────────────────────────
    boot.kernel.sysctl = {
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv4.ip_forward" = 1;
    };

    # Kernel Module für Netzwerk-Bridge
    boot.kernelModules = [ "br_netfilter" "overlay" ];
  };

  # ════════════════════════════════════════════════════════════════════════
  # IMPORTS - Role-specific configs
  # ════════════════════════════════════════════════════════════════════════
  imports = [
    ./master.nix
    ./worker.nix
  ];
}