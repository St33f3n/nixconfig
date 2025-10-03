# font.nix - Fonts

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.fonts-options = {
    enable = mkEnableOption "Collection of fonts and emojis";
  };

  config = mkIf config.misc.enable {

    # ============================================================================
    # SCHRIFTARTEN
    # ============================================================================

    fonts = {
      fontDir.enable = true;
      enableDefaultPackages = true;
      packages = with pkgs; [
        dejavu_fonts
        liberation_ttf
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
      ];
    };

    # HarmonyOS Fonts deaktivieren
    nixpkgs.config.packageOverrides = pkgs: {
      ttf-harmonyos-sans = pkgs.emptyDirectory;
    };
  };
}
