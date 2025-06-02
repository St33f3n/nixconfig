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
      
      # Display Manager & UI Toolkits
      kdePackages.sddm
      sddm-astronaut 
      libsForQt5.qt5.qtwayland
      libsForQt5.qt5.qtquickcontrols2  
      libsForQt5.qt5.qtgraphicaleffects
      qt6.qtwayland
      gtk3
      gtk4
      
      # Desktop Tools
      waybar dunst rofi-wayland wlogout
      swaylock-effects swayidle cliphist
      wl-clipboard wtype ffmpegthumbnailer
      ags udiskie polkit-kde-agent

      
    nerd-fonts.monofur
    nerd-fonts.zed-mono
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    ];

    # System Services
    services.displayManager.sddm = {
      enable = true;
      theme = "astronaut";  
    };
    services.xserver.enable = true;
    programs.hyprland.enable = true;
    
    # Hardware drivers
    boot.extraModulePackages = [ config.boot.kernelPackages.xpadneo ];
  };
}
