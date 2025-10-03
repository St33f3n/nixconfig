{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.lib.formats.rasi) mkLiteral;

  # Stylix wallpaper integration
  wallpaperPath = "${config.home.homeDirectory}/.cache/rofi-wallpapers";
  stylixWallpaper = config.stylix.image;
in
{
  programs.rofi = {
  enable = true;
  theme = ../rofi_theme/art-deco.rasi;
  extraConfig = {
    modi = "drun,run,window";
    show-icons = true;
    icon-theme = "Papirus";
  };
};
}