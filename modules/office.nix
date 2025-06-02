# modules/office.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.office = {
    enable = mkEnableOption "office and productivity tools";
  };

  config = mkIf config.office.enable {
    environment.systemPackages = with pkgs; [
      # Communication
      thunderbird
      protonmail-bridge
      vesktop
      element-desktop
      zapzap
      zoom-us
      
      # Browsers
      mullvad-browser
      
      # Office & Productivity
      libreoffice-qt6-fresh
      anki
      qalculate-gtk
      
      # Document Processing & LaTeX
      texstudio
      texliveFull
      pandoc
      
      # Note Taking & Knowledge Management
      trilium-next-desktop
      
      # Security & Encryption
      rustdesk
      picocrypt
      veracrypt
      
      # Media & Books
      calibre
      spotify
      libation 





(nextcloud-talk-desktop.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];
    
    postFixup = ''
      wrapProgram $out/bin/nextcloud-talk-desktop \
        --set GSETTINGS_SCHEMA_DIR "${glib.getSchemaPath gsettings-desktop-schemas}:${glib.getSchemaPath gtk3}" \
        --set XDG_CURRENT_DESKTOP "Hyprland" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd mesa ]}"
    '';
  }))
      
    ];
  };
}
