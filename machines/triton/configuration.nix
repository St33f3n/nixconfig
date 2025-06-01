# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, inputs, ... }:
let ip_address = "192.168.2.26";

in {
  imports = [
    # Include the results of the hardware scan.
    ./stylix.nix
    ./hardware-configuration.nix

  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "triton"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.interfaces.enp0s13f0u1u2 = {
    ipv4 = {
      addresses = [{
        address = ip_address;
        prefixLength = 24;
      }];
    };
  };

  # networking.interfaces.wlp0s20f3 = {
  #   ipv4 = {
  #     addresses = [{
  #       address = "192.168.2.27";
  #       prefixLength = 24;
  #     }];
  #   };
  # };

  networking.nameservers = [ "192.168.2.32" "192.168.2.1" ];
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 53317 ];
    allowedUDPPorts = [ 53317 22 ];
  };

  # Enable networking
  networking.networkmanager.enable = true;

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
  programs.hyprland.enable = true;
  programs.hyprland.package =
    inputs.hyprland.packages."${pkgs.system}".hyprland;


  services.xserver.enable = true;

  services.displayManager = {
    sddm.enable = true;
  };

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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware = {
    graphics.enable = true;
    nvidia.modesetting.enable = true;
  };
  security.polkit.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.steefen = {
    isNormalUser = true;
    description = "Stefan Simmeth";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  security.sudo.extraRules = [{
    users = [ "steefen" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];
  # Experimental Feature
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    zen-browser
    libsForQt5.qt5.qtwayland
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    dunst
    helix
    ethtool
    wakeonlan
    nerd-fonts.monofur
    nerd-fonts.zed-mono
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    git
    curl
    localsend
    alacritty
    yazi
    nvidia-container-toolkit
    uv
    arduino-ide
    blueman
    cliphist
    zoxide
    noisetorch
    picocrypt
    carapace
    veracrypt
    vorta
    starship
    thunderbird-latest-unwrapped
    zellij
    atuin
    nextcloud-client
    fd
    btop
    nvtopPackages.full
    tldr
    fastfetch
    inotify-tools
    inotify-info
    ethtool
    rustdesk
    spotify
    netcat
    nmap
    bat
    ripgrep
    eza
    direnv
    libreoffice-fresh
    rustup
    nodejs
    pkgs.nix-ld
    nixpkgs-fmt
    protonmail-bridge
    protonvpn-gui
    wireguard-go
    tor-browser
    nixd
    yt-dlp
    dunst
    calibre
    pandoc
    libnotify
    networkmanagerapplet
    home-manager
    libgcc
    typescript-language-server
    qalculate-gtk
    nix-prefetch-git
    kdePackages.sddm
    nixfmt-rfc-style
    nix-tree
    nix-du
    nixpkgs-review
    manix
    statix
    deadnix
    ags
    gimp-with-plugins
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    wget
    fabric-ai
    pkgs.nix-ld
    nixpkgs-fmt
    docker-credential-helpers
    libsecret
    libgnome-keyring
    dconf
    hyprpaper
    bun
    bacon
    lazygit
  ];


  services.dbus.packages = with pkgs; [ dconf ];
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs;
      [
        xdg-desktop-portal-gtk
        #xdg-desktop-portal-hyprland
      ];
    config.common.default = "*";
    config.common.defaultFallback = "gtk";

  };


  


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
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
