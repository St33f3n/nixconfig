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
  ip_address = "192.168.2.26";

in
{
  imports = [
    # Include the results of the hardware scan.
    inputs.sops-nix.nixosModules.sops
    ./stylix.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../modules/core.nix
    ../../modules/desktop.nix
    ../../modules/shell.nix
    ../../modules/dev.nix
    ../../modules/office.nix
    ../../modules/misc.nix
    ../../modules/kubernetes
  ];

  core.enable = true;
  desktop.enable = true;
  shell.enable = true;
  dev.enable = true;
  office.enable = true;
  misc.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "triton";
  networking.networkmanager.enable = true; # Make sure this is explicitly set

  networking.interfaces."enp0s13f0u3u2".wakeOnLan.enable = true;

  sops.secrets.wifi_password = {
    sopsFile = ./secrets/secrets.yaml;
    mode = "0400";
    owner = "root";
  };

  # Use a systemd service to set up the connection with the secret
  systemd.services.setup-wifi = {
    description = "Setup WiFi with secret";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-pre.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.networkmanager}/bin/nmcli connection show "WiFi Fallback" &> /dev/null || \
      ${pkgs.networkmanager}/bin/nmcli connection add \
        type wifi \
        con-name "WiFi Fallback" \
        ifname '*' \
        ssid "Dahoam3" \
        wifi-sec.key-mgmt wpa-psk \
        wifi-sec.psk "$(cat ${config.sops.secrets.wifi_password.path})" \
        ipv4.method manual \
        ipv4.addresses "${ip_address}/24" \
        ipv4.gateway "192.168.2.1" \
        ipv4.dns "192.168.2.32 192.168.2.1" \
        connection.autoconnect yes \
        connection.autoconnect-priority 50
    '';
  };

  networking.networkmanager = {
    ensureProfiles.profiles = {
      "usb-ethernet" = {
        "connection" = {
          "id" = "USB-C Dock";
          "type" = "ethernet";
          "interface-name" = "enp0s13f0u1u2";
          "autoconnect" = true;
          "autoconnect-priority" = 100; # Higher priority
        };
        "ipv4" = {
          "method" = "manual";
          "address1" = "${ip_address}/24,192.168.2.1";
          "dns" = "192.168.2.32;192.168.2.1";
        };
      };

    };
  };
  networking.nameservers = [
    "192.168.2.32"
    "192.168.2.1"
  ];
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

  # ============================================================================
  # BENUTZER KONFIGURATION
  # ============================================================================

  users.users.biocirc = {
    isNormalUser = true;
    description = "Stefan Simmeth";
    extraGroups = [
      "dialout" # Serielle Geräte
      "plugdev" # USB-Geräte
      "input" # Input-Geräte
      "render" # GPU-Zugriff
      "video" # Video-Geräte
      "tty" # TTY-Zugriff
      "networkmanager"
      "wheel" # sudo
      "docker"
      "podman"
    ];
  };

  # Passwortloses sudo für Hauptbenutzer
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
  services.k3s-cluster = {
    agent = {
      enable = true;
      serverAddress = "https://neptune.local:6443";
      tokenFile = config.sops.secrets."k3s_token".path;
      nodeAddress = ip_address;
      nodeLabels = [
      ];

      nodeTaints = [ ];
    };

    storage.client = {
      enable = true;
      serverAddress = "neptune.local";
      serverUser = "k3s-storage";
      remoteDir = "/mnt/test";
      mountPoint = "mnt/test";
      sshKeyFile = config.sops.secrets."nfs_ssh_key".path;
    };
  };

  services.logind.lidSwitch = "ignore";

  # For the other options, use the new nested structure:
  services.logind.settings = {
    Login = {
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
