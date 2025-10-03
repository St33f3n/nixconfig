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
    inputs.sops-nix.nixosModules.sops
    ./stylix.nix
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/desktop.nix
    ../../modules/shell.nix
    ../../modules/dev.nix
    ../../modules/office.nix
    ../../modules/orchestration.nix
    ../../modules/security.nix
    ../../modules/misc.nix
    ../../modules/virt.nix
    ../../modules/creative.nix
    ../../modules/ai.nix
  ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/biocirc/.config/sops/age/keys.txt";

  sops.secrets.ip_address = {
    owner = config.users.users.biocirc.name;
  };

  core.enable = true;
  desktop.enable = true;
  shell.enable = true;
  dev.enable = true;
  office.enable = true;
  misc.enable = true;
  virt.enable = true;
  virt.container.enable = true;
  virt.quemu.enable = false;
  creative.enable = true;
  ai.enable = true;
  orchestration.enable = true;
  security.enable = true; 

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  boot.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
    "amdgpu"
  ];
  services.xserver.videoDrivers = [
    "nvidia"
    "amdgpu"
  ];

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

  # Configure console keymap
  console.keyMap = "de";

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # AMD RX 7700 XT drivers
        mesa
        amdvlk
        rocmPackages.clr.icd

        rocmPackages.rocm-runtime
        # NVIDIA RTX 3070 Ti drivers
        nvidia-vaapi-driver
        libvdpau-va-gl
      ];
    };
    nvidia-container-toolkit.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false; # Not needed for desktop
      open = false; # Use proprietary for RTX 3070 Ti
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

    };

    amdgpu.amdvlk.enable = true;

  };
  environment.systemPackages = with pkgs; [
    nvidia-system-monitor-qt
    orca-slicer
    fabric-ai
    nvtopPackages.full
  ];

  # Environment for dual GPU setup
  environment.sessionVariables = {
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    AMD_VULKAN_ICD = "RADV";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver/share/vulkan/icd.d/radeon_icd.json";
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
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  services.flatpak = {
    enable = true;
    packages = [

      "com.usebottles.bottles"
      "eu.betterbird.Betterbird"
      "org.freecad.FreeCAD"
    ];
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget

  services.dbus.packages = with pkgs; [ dconf ];
  programs.dconf.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.KbdInteractiveAuthentication = false;

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
    # HarmonyOS Fonts aus dem System entfernen
    ttf-harmonyos-sans = pkgs.emptyDirectory;
  };

  services.udev.packages = with pkgs; [ via ];

  services.udev.extraRules = ''
      # QMK/VIA Keyboard Support
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

      # General HID device access for keyboards
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="*", MODE="0666", TAG+="uaccess"


      SUBSYSTEM=="usb", ATTR{idVendor}=="2341", ATTR{idProduct}=="0043", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="usb", ATTR{idVendor}=="2341", ATTR{idProduct}=="8036", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="PCRUDISK", ENV{UDISKS_IGNORE}="1"
  '';

  systemd.services.windmill-compose = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "podman.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    path = with pkgs; [
      podman
      iptables
      gawk
      util-linux
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/etc/containers/windmill";
      ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
      ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
    };
  };

  systemd.services.karakeeper-compose = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "podman.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    path = with pkgs; [
      podman
      iptables
      gawk
      util-linux
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/etc/containers/karakeeper";
      ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
      ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
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
