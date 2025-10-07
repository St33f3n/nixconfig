# modules/kubernetes/master.nix
# Kubernetes Master Node (Control Plane + NFS Server)
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.k8s-cluster.master;
  baseCfg = config.services.k8s-cluster;
  
in
{
  options.services.k8s-cluster.master = {
    enable = mkEnableOption "Kubernetes Master Node mit NFS Server";

    nodeAddress = mkOption {
      type = types.str;
      example = "192.168.2.33";
      description = "IP-Adresse dieses Master Nodes";
    };

    nfs = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "NFS Server für Cluster-Storage aktivieren";
      };

      storageDir = mkOption {
        type = types.str;
        default = "/mnt/k8s-storage";
        description = "Root-Verzeichnis für K8s-Storage (NFS-Export)";
      };

      allowedNetworks = mkOption {
        type = types.listOf types.str;
        default = [ "192.168.2.0/24" ];
        description = "Netzwerke mit NFS-Zugriff";
      };
    };
  };

  config = mkIf cfg.enable {
    # ════════════════════════════════════════════════════════════════════════
    # ASSERTIONS & VALIDATIONS
    # ════════════════════════════════════════════════════════════════════════
    assertions = [
      {
        assertion = baseCfg.masterAddress == cfg.nodeAddress;
        message = "services.k8s-cluster.masterAddress muss gleich services.k8s-cluster.master.nodeAddress sein";
      }
      {
        assertion = !config.services.k8s-cluster.worker.enable;
        message = "Master und Worker können nicht auf demselben Node aktiviert sein (aktuell)";
      }
    ];

    # ════════════════════════════════════════════════════════════════════════
    # KUBERNETES MASTER ROLE
    # ════════════════════════════════════════════════════════════════════════
    services.kubernetes = {
      # KORREKTUR: Rolle nutzen statt manueller Component-Aktivierung
      roles = [ "master" ];

      # KORREKTUR: addonManager wird automatisch durch "master" role aktiviert,
      # aber explizite Aktivierung für Klarheit
      addonManager.enable = true;

      # API Server Konfiguration
      apiserver = {
        advertiseAddress = cfg.nodeAddress;
        serviceClusterIpRange = baseCfg.serviceCidr;
        securePort = 6443;
      };

      # Controller Manager
      controllerManager = {
        extraOpts = "--cluster-cidr=${baseCfg.clusterCidr}";
      };


      # Kubelet für Master (kann auch Pods hosten)
      kubelet = {
        nodeIp = cfg.nodeAddress;
      };
    };

    # ════════════════════════════════════════════════════════════════════════
    # NFS SERVER
    # ════════════════════════════════════════════════════════════════════════
    services.nfs.server = mkIf cfg.nfs.enable {
      enable = true;
      statdPort = 4000;
      lockdPort = 4001;
      exports = ''
        ${cfg.nfs.storageDir} ${
          concatStringsSep " " (
            map (net: "${net}(rw,sync,no_subtree_check,no_root_squash)") cfg.nfs.allowedNetworks
          )
        }
      '';
    };

    # Storage-Verzeichnis erstellen
    systemd.tmpfiles.rules = mkIf cfg.nfs.enable [
      "d ${cfg.nfs.storageDir} 0755 root root -"
    ];

    # ════════════════════════════════════════════════════════════════════════
    # FIREWALL (Master-spezifische Ports)
    # ════════════════════════════════════════════════════════════════════════
    networking.firewall = {
      allowedTCPPorts = [
        # Kubernetes Control Plane
        6443      # API Server (secure port)
        2379 2380 # etcd
        10250     # kubelet API
        10251     # kube-scheduler (wird durch role automatisch konfiguriert)
        10252     # kube-controller-manager (wird durch role automatisch konfiguriert)
      ] ++ optionals cfg.nfs.enable [
        # NFS
        111   # portmapper
        2049  # nfs
        4000  # statd
        4001  # lockd
      ];
      
      allowedUDPPorts = optionals cfg.nfs.enable [
        111   # portmapper
        2049  # nfs
      ];
    };

    # ════════════════════════════════════════════════════════════════════════
    # ZUSÄTZLICHE PACKAGES
    # ════════════════════════════════════════════════════════════════════════
    environment.systemPackages = with pkgs; [
      # Standard kubectl/helm sind bereits in base.nix
    ] ++ optionals cfg.nfs.enable [ 
      nfs-utils 
    ] ++ optionals baseCfg.easyCerts [
       cfssl
    ];

    # ════════════════════════════════════════════════════════════════════════
    # WICHTIGE HINWEISE FÜR DEN BENUTZER
    # ════════════════════════════════════════════════════════════════════════
    warnings = [
      "RBAC Authorization ist aktiviert. Für Admin-Zugriff: export KUBECONFIG=/etc/kubernetes/cluster-admin.kubeconfig"
    ] ++ optionals (!baseCfg.easyCerts) [
      "easyCerts ist deaktiviert. Zertifikate müssen manuell konfiguriert werden für TLS-Kommunikation."
    ];
  };
}