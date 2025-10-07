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
      roles = [ "master" ];

      # API Server
      apiserver = {
        enable = true;
        advertiseAddress = cfg.nodeAddress;
        securePort = 6443;
        serviceClusterIpRange = baseCfg.serviceCidr;
      };

      # Controller Manager
      controllerManager = {
        enable = true;
        extraOpts = "--cluster-cidr=${baseCfg.clusterCidr}";
      };

      # Scheduler
      scheduler.enable = true;

      # etcd (Cluster State Store)
      etcd = {
        enable = true;
        listenClientUrls = [ "http://127.0.0.1:2379" ];
      };

      # Proxy (auch Master braucht kube-proxy)
      proxy.enable = true;

      # Kubelet (Master kann auch Pods hosten, optional)
      kubelet = {
        enable = true;
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
        6443 # API Server
        2379
        2380 # etcd
        10250 # kubelet API
        10251 # kube-scheduler
        10252 # kube-controller-manager
      ] ++ optionals cfg.nfs.enable [
        # NFS
        111
        2049
        4000
        4001
      ];
      allowedUDPPorts = optionals cfg.nfs.enable [
        111
        2049
      ];
    };

    # ════════════════════════════════════════════════════════════════════════
    # ZUSÄTZLICHE PACKAGES
    # ════════════════════════════════════════════════════════════════════════
    environment.systemPackages = with pkgs; [ ] ++ optionals cfg.nfs.enable [ nfs-utils ];
  };
}