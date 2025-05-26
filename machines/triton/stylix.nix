{ pkgs, inputs, ... }: let

color_scheme = {
    base00 = "202d36"; # midnight
    base08 = "ff4500"; # coral_red
    base07 = "1d4d4f"; # kelp_green
    base05 = "ffcc99"; # beige
    base03 = "0088cc"; # coral_blue
    base09 = "d65d52"; # coral_deep
    base0B = "00c2c2"; # bioluminescent
    base0F = "a3b8c2"; # seafoam_gray
    base01 = "141e26"; # abyss
    base0E = "ff6347"; # coral_orange
    base0C = "2d8a8a"; # sea_foam
    base02 = "ffa07a"; # coral_light
    base0A = "006666"; # deep_teal
    base0D = "006bb3"; # marine_blue
    base04 = "004d66"; # deep_sapphire
    base06 = "e6f3f7"; # text_primary
  };

  imgLink = "https://nextcloud.organiccircuitlab.com/s/8mcMtc74RxcaBSz";

  image = pkgs.fetchurl {
    url = imgLink;
    sha256 = "1k5cf0q3ycgcfk195hdngg89r15z0zyfb5xmmr1w79xfs5c0iihh";
  };
  
in{
  
  stylix.autoEnable = true;

  stylix.targets.gtk.enable = true;
  stylix.base16Scheme = color_scheme;
  stylix.image = image;
  
  stylix.cursor.package = pkgs.qogir-icon-theme;
  stylix.cursor.name = "Qogir-dark";
  stylix.cursor.size = 24;

  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.martian-mono;
      name = "MartianMono Nerd Font";
    };
    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };
    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };

  services.colord.enable = true; # Ensure colord is running
  environment.sessionVariables = {
    WAYLAND_DISPLAY = "wayland-0"; # Or whatever your Wayland display is named
    COLORSCHEME =
      builtins.toJSON color_scheme; # Export the color scheme
  };
}
