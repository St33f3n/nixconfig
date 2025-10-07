# modules/kubernetes/worker.nix
# Kubernetes Worker Node mit NFS Client
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.k8s-cluster.worker;
  baseCfg = config.services.k8s-cluster;
in
{
  options.services.k8s-cluster.worker = {
    enable = mkEnableOption "Kubernetes Worker Node mit NFS Client";

    nodeAddress = mkOption {
      type = types.str;
      example = "192.168.2.56";
      description = "IP-Adresse dieses Worker Nodes";
    };

    nfs = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "NFS Client für Cluster-Storage aktivieren";
      };

      serverAddress = mkOption {
        type = types.str;
        example = "192.168.2.33";
        description = "IP-Adresse des NFS Servers (Master)";
      };

      storageDir = mkOption {
        type = types.str;
        default = "/mnt/k8s-storage";
        description = "NFS Mount Point auf diesem Worker";
      };
    };

    labels = {
      priority = mkOption {
        type = types.enum [
          "high"
          "low"
        ];
        default = "low";
        description = "Node-Priorität (high = always-on, low = on-demand)";
      };

      powerState = mkOption {
        type = types.enum [
          "always-on"
          "on-demand"
        ];
        default = "on-demand";
        description = "Power-State des Nodes";
      };

      customLabels = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          "gpu" = "nvidia";
          "disk" = "ssd";
        };
        description = "Zusätzliche Custom Labels für Scheduling";
      };
    };
  };

  config = mkIf cfg.enable {
    # ════════════════════════════════════════════════════════════════════════
    # ASSERTIONS & VALIDATIONS
    # ════════════════════════════════════════════════════════════════════════
    assertions = [
      {
        assertion = !config.services.k8s-cluster.master.enable;
        message = "Master und Worker können nicht auf demselben Node aktiviert sein (aktuell)";
      }
      {
        assertion = cfg.nfs.enable -> cfg.nfs.serverAddress != "";
        message = "services.k8s-cluster.worker.nfs.serverAddress muss gesetzt sein wenn NFS aktiviert";
      }
    ];

    # ════════════════════════════════════════════════════════════════════════
    # KUBERNETES WORKER ROLE
    # ════════════════════════════════════════════════════════════════════════
    services.kubernetes = {
      roles = [ "node" ];

      # Kubelet (Worker-Agent)
      kubelet = {
        enable = true;
        nodeIp = cfg.nodeAddress;

        # Node Labels für Scheduling
        extraOpts =
          let
            labelString = concatStringsSep "," (
              [ "node-priority=${cfg.labels.priority}" "power-state=${cfg.labels.powerState}" ]
              ++ (mapAttrsToList (k: v: "${k}=${v}") cfg.labels.customLabels)
            );
          in
          "--node-labels=${labelString}";
      };

      # Kube-Proxy
      proxy.enable = true;
    };

    # ════════════════════════════════════════════════════════════════════════
    # NFS CLIENT
    # ════════════════════════════════════════════════════════════════════════
    services.rpcbind.enable = mkIf cfg.nfs.enable true;

    # Mount-Point erstellen
    systemd.tmpfiles.rules = mkIf cfg.nfs.enable [
      "d ${cfg.nfs.storageDir} 0755 root root -"
    ];

    # NFS Mount
    fileSystems."${cfg.nfs.storageDir}" = mkIf cfg.nfs.enable {
      device = "${cfg.nfs.serverAddress}:${cfg.nfs.storageDir}";
      fsType = "nfs4";
      options = [
        "rw"
        "soft" # Soft mount für bessere Recovery
        "intr" # Interruptible
        "timeo=30" # 3s timeout
        "retrans=2" # 2 retry attempts
        "rsize=32768" # Read size 32KB
        "wsize=32768" # Write size 32KB
      ];
    };

    # ════════════════════════════════════════════════════════════════════════
    # FIREWALL (Worker-spezifische Ports)
    # ════════════════════════════════════════════════════════════════════════
    networking.firewall = {
      allowedTCPPorts = [
        10250 # kubelet API
        30000
        32767 # NodePort Services Range
      ];
    };

    # ════════════════════════════════════════════════════════════════════════
    # ZUSÄTZLICHE PACKAGES
    # ════════════════════════════════════════════════════════════════════════
    environment.systemPackages = with pkgs; [ ] ++ optionals cfg.nfs.enable [ nfs-utils ];
  };
}