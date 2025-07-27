# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  ...
}:
let
  ip_address = "192.168.2.56";

in
{
  imports = [
    # Include the results of the hardware scan.
    ./stylix.nix
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/desktop.nix
    ../../modules/shell.nix
    ../../modules/dev.nix
    ../../modules/office.nix
    ../../modules/misc.nix
    ../../modules/virt.nix
    ../../modules/creative.nix
    ../../modules/ai.nix
  ];

  core.enable = true;
  desktop.enable = true;
  shell.enable = true;
  dev.enable = true;
  office.enable = true;
  misc.enable = true;
  virt.enable = true;
  creative.enable = true;
  ai.enable = false;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "neptune"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #

  networking.networkmanager = {
    ensureProfiles.profiles = {
      "usb-ethernet" = {
        "connection" = {
          "id" = "Local";
          "type" = "ethernet";
          "interface-name" = "enp9s0";
          "autoconnect" = true;
        };
        "ipv4" = {
          "method" = "manual";
          "address1" = "${ip_address}/24,192.168.2.1";
          "dns" = "192.168.2.32;192.168.2.1";
        };
      };
    };
  };

  networking.firewall = {
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

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
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

  #Hyprland
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

  environment = {
    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      COLORSCHEME = builtins.toJSON config.stylix.base16Scheme;
    };
  };
  stylix.enable = true;

  home-manager.backupFileExtension = "../backup";

  # Configure console keymap
  console.keyMap = "de";

  hardware = {
    nvidia.modesetting.enable = true;
  };

  users.users.biocirc = {
    isNormalUser = true;
    description = "Stefan Simmeth";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
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
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.flatpak = {
    enable = true;
    packages = [
      "com.usebottles.bottles"
    ];
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    orca-slicer
    fabric-ai
  ];

  services.dbus.packages = with pkgs; [ dconf ];
  programs.dconf.enable = true;

  # Enable the OpenSSH daemon.
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
