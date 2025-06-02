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
      # nextcloudtalk  # Note: Verify package name
      zoom-us
      
      # Browsers
      mullvad-browser
      # zen-browser - Add via flake packages in configuration.nix
      
      # Office & Productivity
      libreoffice-fresh
      anki
      qalculate-gtk
      
      # Document Processing & LaTeX
      texstudio
      texlive.combined.scheme-full
      pandoc
      
      # Note Taking & Knowledge Management
      # trilium-notes  # Note: Verify correct package name
      
      # Security & Encryption
      rustdesk
      picocrypt
      veracrypt
      
      # Media & Books
      calibre
      spotify
      # libation  # Note: Verify package name
    ];
  };
}
