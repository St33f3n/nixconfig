# modules/desktop.nix
{ config, lib, pkgs, ... }:

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
      # Display Manager & UI Toolkits
      kdePackages.sddm
      (sddm-astronaut.override { embeddedTheme = "astronaut";}) 
      libsForQt5.qt5.qtwayland
      libsForQt5.qt5.qtquickcontrols2  
      libsForQt5.qt5.qtgraphicaleffects
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      qt6.qtwayland
      gtk3
      gtk4
      
      # Desktop Tools
      waybar dunst rofi-wayland wlogout
      swaylock-effects swayidle cliphist
      wl-clipboard wtype ffmpegthumbnailer
      ags udiskie 

    kdePackages.polkit-kde-agent-1

    grim
    slurp
    wf-recorder
    grimblast
      
    nerd-fonts.monofur
    nerd-fonts.zed-mono
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    ];

    # System Services
    services.displayManager.sddm = {
      enable = true;
      theme = "sddm-astronaut-theme";  
    };
    services.xserver.enable = true;
    programs.hyprland.enable = true;
    
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs;
        [
          xdg-desktop-portal-gtk
        ];
      config.common = {
      default = "*";
      defaultFallback = "gtk";
      };

    };
    # Hardware drivers
    boot.extraModulePackages = [ config.boot.kernelPackages.xpadneo ];
  };
}
