# modules/virtualization.nix
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

    docker = {
      enable = mkEnableOption "Docker container platform";
    };

    quemu = {
      enable = mkEnableOption "KVM/QEMU virtualization with virt-manager";
    };
  };

  config = mkIf config.virt.enable (mkMerge [
    # Docker Configuration
    (mkIf config.virt.docker.enable {
      environment.systemPackages = with pkgs; [
        distrobox
        docker
        docker-buildx
        docker-compose
        docker-credential-helpers
      ];

      virtualisation.docker = {
        enable = true;
        enableNvidia = false; # Keep this false
        package = pkgs.docker_25; # Use Docker 25+ for CDI support
        daemon.settings = {
          default-runtime = "runc";
          features.cdi = true; # Enable CDI support
        };
      };

      hardware.nvidia-container-toolkit.enable = true;
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
  ]);
}
