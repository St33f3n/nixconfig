# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  ip_address = "192.168.2.33";
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/biocirc/.config/sops/age/keys.txt";

  sops.secrets.ip_address = {
    owner = config.users.users.biocirc.name;
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "labmaster";

  boot.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"

  ];
  services.xserver.videoDrivers = [
    "nvidia"

  ];

  networking.interfaces.enp4s0 = {
    ipv4 = {
      addresses = [
        {
          address = ip_address;
          prefixLength = 24;
        }
      ];

      routes = [
        {
          address = "0.0.0.0";
          prefixLength = 0;
          via = "192.168.2.1";
        }
      ];
    };
  };

  networking.nameservers = [
    "192.168.2.32"
    "192.168.2.1"
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
      53317
    ];
    allowedUDPPorts = [
      53317
      22
    ];

  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver.enable = true;
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

  environment = {
    sessionVariables = {
      XDG_RUNTIME_DIR = "/run/user/$UID";
      GNOME_KEYRING_CONTROL = "/run/user/1000/keyring";
      ROCR_VISIBLE_DEVICES = 0;
      HIP_VISIBLE_DEVICES = 0;
      HSA_OVERRIDE_GFX_VERSION = "11.0.1";
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      COLORSCHEME = builtins.toJSON config.stylix.base16Scheme;
    };
  };
  stylix.enable = true;
  home-manager.backupFileExtension = "../backup";

  console.keyMap = "de";

  services.printing.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libvdpau-va-gl
      ];
    };
    nvidia-container-toolkit.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

    };

  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    jack.enable = true;

  };

  users.users.biocirc = {
    isNormalUser = true;
    description = "Stefan Simmeth";
    extraGroups = [
      "dialout"
      "plugdev"
      "input"
      "render"
      "video"
      "tty"
      "networkmanager"
      "wheel"
      "docker"
      "podman"
    ];
  };
  security.sudo.extraRules = [
    {
      users = [ "biocirc" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  # Experimental Feature
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.dbus.packages = with pkgs; [ dconf ];
  programs.dconf.enable = true;

  fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;

  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];
  nixpkgs.config.packageOverrides = pkgs: {
    ttf-harmonyos-sans = pkgs.emptyDirectory;
  };

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.KbdInteractiveAuthentication = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
