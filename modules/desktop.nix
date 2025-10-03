# desktop.nix - Desktop Environment & UI

{ config, lib, pkgs, inputs, ... }:

with lib;

{
  options.desktop = {
    enable = mkEnableOption "hyprland desktop environment";
  };

  config = mkIf config.desktop.enable {
    environment.systemPackages = with pkgs; [
      # Compositor & Core
      hyprland
      xwayland
      niri

      # Display Manager
      kdePackages.sddm
      (sddm-astronaut.override { embeddedTheme = "astronaut"; })

      # Qt Libraries
      libsForQt5.qt5.qtwayland
      libsForQt5.qt5.qtquickcontrols2
      libsForQt5.qt5.qtgraphicaleffects
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtwayland
      qt6.qtsvg
      qt6.qtimageformats
      qt6.qtmultimedia
      qt6.qt5compat
      qt6.qttools

      # GTK
      gtk3
      gtk4

      # XDG Portal
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk

      # Desktop Tools
      waybar
      dunst
      rofi
      wlogout
      swaylock-effects
      swayidle
      cliphist
      wl-clipboard
      wtype
      ags
      udiskie
      kdePackages.polkit-kde-agent-1
      (inputs.quickshell.packages.x86_64-linux.default.override {
        withJemalloc = true;
        withHyprland = true;
        withQtSvg = true;
        withPipewire = true;
      })

      # Screenshot & Recording
      grim
      slurp
      wf-recorder
      grimblast

      # Fonts
      nerd-fonts.monofur
      nerd-fonts.zed-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono

      # Theme
      qogir-icon-theme
    ];

    # Qt Configuration
    qt.enable = true;

    # System Services
    services.displayManager.sddm = {
      enable = true;
      theme = "sddm-astronaut-theme";
    };

    services.xserver.enable = true;

    # Compositor Programs
    programs.hyprland.enable = true;
    programs.niri.enable = true;

    # XDG Portal Configuration
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.common = {
        default = "*";
        defaultFallback = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gnome" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
    };

    # Hardware drivers
    boot.extraModulePackages = [ config.boot.kernelPackages.xpadneo ];
  };
}