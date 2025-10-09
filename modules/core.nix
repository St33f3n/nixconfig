# core.nix - Basis-System, das auf jeder Maschine läuft

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.core = {
    enable = mkEnableOption "core system packages and services";
  };

  config = mkIf config.core.enable {
    environment.systemPackages = with pkgs; [
      # System Libraries & Infrastructure
      libgcc
      libsecret
      dconf
      libnotify
      glib
      glibc
      glibtool
      gsettings-desktop-schemas
      openssl

      # Network Management
      networkmanagerapplet
      iwd
      usb-modeswitch

      # Browsers
      librewolf

      # File Management & Sync
      localsend
      nextcloud-client
      filezilla
      rsync
      exfatprogs

      # USB Tools
      usbutils
      popsicle
    ];

    # Essential Hardware Support
    hardware = {
      graphics.enable = true;
      bluetooth.enable = true;
    };

    # Essential System Services
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
      openssh.enable = true;
      devmon.enable = true;
      gvfs.enable = true;
      udisks2.enable = true;
      gnome.gnome-keyring.enable = true;
    };

    # Security & System Essentials
    security = {
      rtkit.enable = true;
      polkit.enable = true;
      pam.services.login.enableGnomeKeyring = true;
    };

    # Programs requiring system-level setup
    programs = {
      dconf.enable = true;
      seahorse.enable = true;
      direnv.enable = true;
    };

    # Basic firewall
    networking = {
      firewall.enable = true;
      networkmanager.enable = true;
    };
  };
}
