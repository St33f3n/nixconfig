# virt.nix - Virtualization & Containers

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.virt = {
    enable = mkEnableOption "trigger virtualisation";
    container = {
      enable = mkEnableOption "Container platform";
    };
    quemu = {
      enable = mkEnableOption "KVM/QEMU virtualization with virt-manager";
    };
    kubernetes = {
      enable = mkEnableOption "Observation & Kontroll over Kubernetes";
    };
  };

  config = mkIf config.virt.enable (mkMerge [
    # Container Configuration
    (mkIf config.virt.container.enable {
      environment.systemPackages = with pkgs; [
        distrobox
        podman-compose
        podman-desktop
        podman-tui
        skopeo
        buildah
        dive
        nethogs
        compose2nix
      ];

      virtualisation = {
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings = {
            dns_enabled = true;
            ipv6_enabled = false;
          };
          autoPrune = {
            enable = true;
            dates = "weekly";
            flags = [
              "--all"
              "--volumes"
            ];
          };
        };

        containers = {
          enable = true;
          containersConf.settings = {
            containers = {
              log_driver = "journald";
              events_logger = "journald";
              runtime = "crun";
            };
          };
        };

        oci-containers.backend = "podman";
      };

      hardware.nvidia-container-toolkit.enable = true;

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          80
          443
          8080
          9000
        ];
        allowedTCPPortRanges = [
          {
            from = 1024;
            to = 65535;
          }
        ];
      };
    })
    # Kubernetes Observation Kit
    (mkIf config.virt.kubernetes.enable {
      environment.systemPackages = with pkgs; [
        k9s
        fluxcd
        helm
        kustomize
        stern
        kubectx
      ];
    })

    
    # KVM/QEMU Virtualization Configuration
    (mkIf config.virt.quemu.enable {
      environment.systemPackages = with pkgs; [
        qemu_full
        virt-manager
        virt-viewer
      ];

      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = false;
        };
      };

      programs.virt-manager.enable = true;
    })

    # Game Streaming
    {
      environment.systemPackages = with pkgs; [
        moonlight-qt
        sunshine
      ];
    }
  ]);
}
