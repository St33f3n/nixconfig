# ============================================================================
# Neptune Workstation Configuration
# ============================================================================
# High-performance development workstation with dual GPU setup:
# - AMD RX 7700 XT (primary display/compute)
# - NVIDIA RTX 3070 Ti (CUDA/AI workloads)
# ============================================================================

{
  config,
  pkgs,
  inputs,
  ...
}:

let
  # Netzwerk-Konfiguration
  ip_address = "192.168.2.56";
in

{
  # ============================================================================
  # IMPORTS - Module und Hardware-Konfiguration
  # ============================================================================

  imports = [
    # Secrets Management
    inputs.sops-nix.nixosModules.sops

    # Machine-specific
    ./stylix.nix
    ./hardware-configuration.nix

    # Feature Modules
    ../../modules/core.nix
    ../../modules/desktop.nix
    ../../modules/shell.nix
    ../../modules/dev.nix
    ../../modules/office.nix
    ../../modules/font.nix
    ../../modules/orchestration.nix
    ../../modules/security.nix
    ../../modules/misc.nix
    ../../modules/virt.nix
    ../../modules/creative.nix
    ../../modules/ai.nix
    ../../modules/kubernetes
  ];

  # ============================================================================
  # SECRETS MANAGEMENT (SOPS)
  # ============================================================================

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/biocirc/.config/sops/age/keys.txt";

  sops.secrets.ip_address = {
    owner = config.users.users.biocirc.name;
  };

  # ============================================================================
  # MODULE AKTIVIERUNG
  # ============================================================================

  core.enable = true;
  desktop.enable = true;
  shell.enable = true;
  dev.enable = true;
  office.enable = true;
  fonts-options.enable = true;
  misc.enable = true;
  virt.enable = true;
  virt.container.enable = true;
  virt.quemu.enable = false;
  creative.enable = true;
  ai.enable = true;
  orchestration.enable = true;
  security.enable = true;

  # ============================================================================
  # BOOT KONFIGURATION
  # ============================================================================

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true; 
  };

  # GPU Kernel Module (Dual-GPU Setup)
  boot.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
    "amdgpu"
  ];

  # ============================================================================
  # NETZWERK KONFIGURATION
  # ============================================================================

  networking.hostName = "neptune";
  networking.extraHosts = "192.168.2.56 master.k8s.local etcd.local";


  # Video Treiber für beide GPUs
  services.xserver.videoDrivers = [
    "nvidia"
    "amdgpu"
  ];

  # Statische IP-Konfiguration für lokales Netzwerk
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

  # Firewall-Regeln
  networking.firewall = {
    allowedTCPPorts = [
      22 # SSH
      80 # HTTP
      443 # HTTPS
      53317 # LocalSend
    ];
    allowedUDPPorts = [
      53317 # LocalSend
      22 # SSH
    ];
  };

  # ============================================================================
  # LOKALISIERUNG
  # ============================================================================

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

  console.keyMap = "de";

  # ============================================================================
  # DESKTOP ENVIRONMENT - Hyprland Spezifisch
  # ============================================================================

  # Hyprland aus Flake Input
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

  # Umgebungsvariablen für Wayland/Hyprland

  environment.sessionVariables = {
    # AMD GPU Konfiguration
    ROCR_VISIBLE_DEVICES = 0;
    HIP_VISIBLE_DEVICES = 0;
    HSA_OVERRIDE_GFX_VERSION = "11.0.1";

  };

  # Stylix Theming System
  stylix.enable = true;

  # Home-Manager Backup-Konfiguration
  home-manager.backupFileExtension = "../backup";

  # ============================================================================
  # HARDWARE KONFIGURATION - Dual GPU Setup
  # ============================================================================

  hardware = {
    # Graphics/OpenGL Support
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # AMD RX 7700 XT Treiber
        mesa
        amdvlk
        rocmPackages.clr.icd
        rocmPackages.rocm-runtime

        # NVIDIA RTX 3070 Ti Treiber
        nvidia-vaapi-driver
        libvdpau-va-gl
      ];
    };

    # NVIDIA Container Support für AI/ML Workloads
    nvidia-container-toolkit.enable = true;

    # NVIDIA GPU Konfiguration
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false; # Nicht nötig für Desktop
      open = false; # Proprietäre Treiber für RTX 3070 Ti
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # AMD GPU Konfiguration
    amdgpu.amdvlk.enable = true;
  };

  # GPU-spezifische Tools
  environment.systemPackages = with pkgs; [
    nvidia-system-monitor-qt
    orca-slicer
    fabric-ai
    nvtopPackages.full
  ];

  # Umgebungsvariablen für Dual-GPU Setup
  environment.sessionVariables = {
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    AMD_VULKAN_ICD = "RADV";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver/share/vulkan/icd.d/radeon_icd.json";
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

  # ============================================================================
  # NIX KONFIGURATION
  # ============================================================================

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nixpkgs.config.allowUnfree = true;

  # ============================================================================
  # SYSTEM PROGRAMME & DIENSTE
  # ============================================================================

  # Browser
  programs.firefox.enable = true;

  # AppImage Support
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Flatpak Pakete
  services.flatpak = {
    enable = true;
    packages = [
      "com.usebottles.bottles"
      "eu.betterbird.Betterbird"
      "org.freecad.FreeCAD"
    ];
  };

  # D-Bus & DConf
  services.dbus.packages = with pkgs; [ dconf ];
  programs.dconf.enable = true;

  # ============================================================================
  # HARDWARE-SPEZIFISCHE UDEV REGELN
  # ============================================================================

  services.udev.packages = with pkgs; [ via ];

  services.udev.extraRules = ''
    # QMK/VIA Keyboard Support
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

    # General HID device access for keyboards
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="*", MODE="0666", TAG+="uaccess"

    # Arduino Support
    SUBSYSTEM=="usb", ATTR{idVendor}=="2341", ATTR{idProduct}=="0043", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="usb", ATTR{idVendor}=="2341", ATTR{idProduct}=="8036", MODE="0666", GROUP="dialout"

    # PCR USB Disk ignorieren
    SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="PCRUDISK", ENV{UDISKS_IGNORE}="1"
  '';

  # ============================================================================
  # CONTAINER SERVICES (Podman Compose)
  # ============================================================================

  # Windmill Workflow Engine
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

  # Karakeeper Service
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

  # ════════════════════════════════════════════════════════════════════════
  # KUBERNETES MASTER
  # ════════════════════════════════════════════════════════════════════════
  services.k8s-cluster = {
    # Shared config 
    masterAddress = "master.k8s.local";
    clusterName = "homelab";
    clusterCidr = "10.244.0.0/16";
    serviceCidr = "10.96.0.0/12";
    clusterDns = "10.96.0.10";

    # Master aktivieren 
    master = {
      enable = true;
      nodeAddress = "master.k8s.local";

      nfs = {
        enable = true;
        storageDir = "/mnt/test";
        allowedNetworks = [ "192.168.2.0/24" ];
      };
    };

    # Worker deaktivieren 
    worker.enable = false;
  };

  environment.sessionVariables = {
     KUBECONFIG = "/etc/kubernetes/cluster-admin.kubeconfig";
  };


  # ============================================================================
  # SYSTEM VERSION
  # ============================================================================

  # NixOS Release Version - NICHT ÄNDERN nach der ersten Installation!
  system.stateVersion = "24.05";
}
