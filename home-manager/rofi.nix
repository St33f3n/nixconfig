{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.rofi = {
    enable = true;
    theme = ./rofi_theme/art-deco.rasi;
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Qogir-Dark";

      # Display-Namen
      display-drun = "  Applications";
      display-run = "  Command";
      display-window = "  Windows";

      # Format
      drun-display-format = "{name}";
      font = "JetBrains Mono 11";

      # Position
      location = 0;
      xoffset = 0;
      yoffset = 0;
    };
  };
}
