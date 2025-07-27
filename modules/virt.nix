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

  config = mkMerge [
    # Docker Configuration
    (mkIf config.virt.docker.enable {
      environment.systemPackages = with pkgs; [
        docker
        docker-buildx
        docker-compose
        nvidia-container-toolkit
        docker-credential-helpers
      ];

      virtualisation.docker = {
        enable = true;
        enableNvidia = true; # Enable if you have NVIDIA GPU
      };
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
  ];
}
