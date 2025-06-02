# modules/core.nix - Clean separation of concerns
{ config, lib, pkgs, ... }:

with lib;

{
  options.core = {
    enable = mkEnableOption "core system packages and services";
  };

  config = mkIf config.core.enable {
    # Core system packages - your admin essentials
    environment.systemPackages = with pkgs; [
      # System Libraries & Infrastructure
      libgcc
      libsecret
      dconf
      libnotify
      
      # Security & Secrets
      keepassxc
      
      # Audio & Bluetooth
      noisetorch
      bluez
      bluez-utils
      blueman
      
      # Network Management Tools
      networkmanagerapplet
      iwd
      usb_modeswitch
      
      # Terminal & CLI Tools
      alacritty
      yazi
      eza
      fd
      zoxide
      dust
      direnv
      ripgrep
      bat
      jq
      
      # Editors
      helix
      nano
      
      # Development
      git
      lazygit
      rustup
      python3
      uv
      
      # System Monitoring
      btop
      nvtopPackages.full
      fastfetch
      
      # Network Tools
      ethtool
      inotify-tools
      inotify-info
      nmap
      netcat
      net-tools
      wakeonlan
      dnsmasq
      bridge-utils
      
      # File Management & Sync
      localsend
      nextcloud-client
      filezilla
      rsync
      borgbackup
      
      # Documentation
      tealdeer
      
      # Print System
      cups
    ];

    # Essential Hardware Support - Foundation only
    hardware = {
      graphics.enable = true;        # Every machine has some GPU
      bluetooth.enable = true;       # Most modern machines
    };

    # Essential System Services - Foundation only
    services = {
      # Audio System
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
      
      # Basic services every machine needs
      blueman.enable = true;
      printing.enable = true;
      networkmanager.enable = true;  # Basic enable, no config
      openssh.enable = true;         # Basic enable, no settings
    };

    # Security & System Essentials
    security = {
      rtkit.enable = true;   # Required for pipewire
      polkit.enable = true;  # Essential for desktop operations
    };

    # Basic firewall (machines configure specific rules)
    networking.firewall.enable = true;

    # Programs requiring system-level setup
    programs = {
      direnv.enable = true;
    };
  };
}
