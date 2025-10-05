{ pkgs, inputs, ... }:
let

  color_scheme = {
    base00 = "1e1e1e"; # Default Background (abyss - darker anthracite)
    base01 = "262626"; # Lighter Background (deep-water - für status bars)
    base02 = "6b8e6b"; # Selection Background (sea-foam morandi green)
    base03 = "4a4a4a"; # Comments, Invisibles (normal black - lighter for visibility)
    base04 = "c4b89f"; # Dark Foreground (text-muted warm beige)
    base05 = "f7f2e3"; # Default Foreground (text-primary warm beige)
    base06 = "f7f2e3"; # Light Foreground (bright_foreground)
    base07 = "ffffff"; # Light Background (white bright)
    base08 = "c84a2c"; # Variables/Red (coral-red dimmed)
    base09 = "d49284"; # Integers/Orange (coral-light dimmed)
    base0A = "d49284"; # Classes/Yellow (coral-light dimmed)
    base0B = "6b8e6b"; # Strings/Green (sea-foam morandi green)
    base0C = "5a9a9a"; # Support/Cyan (bioluminescent morandi teal)
    base0D = "c4b89f"; # Functions/Blue (coral-blue softer)
    base0E = "b85347"; # Keywords/Magenta (coral-deep dimmed)
    base0F = "8a9a8a"; # Deprecated (seafoam-gray)
  };

  imgLink = "https://nextcloud.organiccircuitlab.com/s/8mcMtc74RxcaBSz/download/rocket_launch.jpg";

  image = pkgs.fetchurl {
    url = imgLink;
    sha256 = "16rbyymlczjz8i00kmkdfaxzih3d7drjj5xkc35rld91q1pjzrmi";
  };

in
{

  stylix.autoEnable = true;
  stylix.targets.gtk.enable = true;
  stylix.targets.qt.enable = true;
  stylix.base16Scheme = color_scheme;
  stylix.image = image;

  stylix.cursor.package = pkgs.qogir-icon-theme;
  stylix.cursor.name = "Qogir-Dark";
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

  environment.systemPackages = with pkgs; [
    libsForQt5.qt5ct
    qt6ct
    libsForQt5.qtstyleplugins
  ];

  services.colord.enable = true; # Ensure colord is running
  environment.sessionVariables = {
    XCURSOR_THEME = "Qogir-Dark";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Qogir-Dark";
    HYPRCURSOR_SIZE = "24";

    WAYLAND_DISPLAY = "wayland-0"; # Or whatever your Wayland display is named
    COLORSCHEME = builtins.toJSON color_scheme; # Export the color scheme
  };
}
