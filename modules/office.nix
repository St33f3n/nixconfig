# office.nix - Office & Productivity

{ config, lib, pkgs, ... }:

with lib;

{
  options.office = {
    enable = mkEnableOption "office and productivity tools";
  };

  config = mkIf config.office.enable {
    environment.systemPackages = with pkgs; [
      # Communication
      protonmail-bridge
      vesktop
      element-desktop
      zapzap
      zoom-us
      (nextcloud-talk-desktop.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];
        postFixup = ''
          wrapProgram $out/bin/nextcloud-talk-desktop \
            --set GSETTINGS_SCHEMA_DIR "${glib.getSchemaPath gsettings-desktop-schemas}:${glib.getSchemaPath gtk3}" \
            --set XDG_CURRENT_DESKTOP "Hyprland" \
            --prefix LD_LIBRARY_PATH : "${
              lib.makeLibraryPath [
                libglvnd
                mesa
              ]
            }"
        '';
      }))

      # Office & Productivity
      libreoffice-qt6-fresh
      anki
      qalculate-gtk
      font-manager
      simple-scan

      # Document Processing & LaTeX
      pandoc
      haskellPackages.pandoc-crossref
      texliveFull
      espanso-wayland

      # Note Taking
      trilium-next-desktop
    ];

    # Espanso Configuration
    services.espanso = {
      enable = true;
      package = pkgs.espanso-wayland;
    };

    systemd.user.services.espanso = {
      path = [
        pkgs.eza
        pkgs.git
        pkgs.coreutils
        pkgs.bash
      ];
    };

    # Print System
    services.printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}