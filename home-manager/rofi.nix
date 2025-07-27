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
    package = pkgs.rofi-wayland;

    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      display-drun = "Apps";
      display-run = "Commands";
      display-window = "Windows";
      drun-display-format = "{name}";
      window-format = "{w} {c} {t}";
      font = "MartianMono Nerd Font 12";
      icon-theme = "Qogir-Dark";

      # Layout Einstellungen
      lines = 7;
      columns = 1;
      cycle = true;
      scroll-method = 1;
      disable-history = false;
    };

    theme = {
      # Hauptfenster
      window = {
        height = lib.mkForce (mkLiteral "900px");
        width = lib.mkForce (mkLiteral "1400px");
        transparency = lib.mkForce "real";
        fullscreen = lib.mkDefault false;
        enabled = lib.mkDefault true;
        cursor = lib.mkDefault "default";
        spacing = lib.mkDefault (mkLiteral "0em");
        padding = lib.mkDefault (mkLiteral "2em");
        border = lib.mkForce (mkLiteral "2px solid");
        border-color = lib.mkForce (mkLiteral "@ocean-abyss");
        border-radius = lib.mkForce (mkLiteral "2em");
        background-color = lib.mkForce (mkLiteral "@main-bg-darker");
      };

      mainbox = {
        enabled = lib.mkDefault true;
        spacing = lib.mkDefault (mkLiteral "0em");
        padding = lib.mkDefault (mkLiteral "0em");
        orientation = lib.mkForce (mkLiteral "horizontal");
        children = lib.mkForce [
          "sidebar"
          "central-area"
        ];
        background-color = lib.mkDefault (mkLiteral "transparent");
      };

      # Sidebar für Modi-Switcher
      sidebar = {
        spacing = lib.mkDefault (mkLiteral "1em");
        padding = lib.mkForce (mkLiteral "2em 1em");
        width = lib.mkForce (mkLiteral "200px");
        expand = lib.mkDefault false;
        orientation = lib.mkForce (mkLiteral "vertical");
        children = lib.mkForce [ "mode-switcher" ];
        background-color = lib.mkForce (mkLiteral "@ocean-abyss");
        border-radius = lib.mkForce (mkLiteral "1.5em 0em 0em 1.5em");
      };

      # Zentraler Bereich für Apps
      central-area = {
        spacing = lib.mkDefault (mkLiteral "0em");
        padding = lib.mkForce (mkLiteral "2em");
        expand = lib.mkDefault true;
        orientation = lib.mkForce (mkLiteral "vertical");
        children = lib.mkForce [
          "inputbar"
          "listview-container"
        ];
        background-color = lib.mkDefault (mkLiteral "transparent");
      };

      listview-container = {
        spacing = lib.mkDefault (mkLiteral "0em");
        padding = lib.mkDefault (mkLiteral "1em");
        children = lib.mkForce [ "listview" ];
        background-color = lib.mkDefault (mkLiteral "transparent");
      };

      # Mode Switcher
      mode-switcher = {
        orientation = lib.mkForce (mkLiteral "vertical");
        enabled = lib.mkDefault true;
        spacing = lib.mkForce (mkLiteral "1em");
        background-color = lib.mkDefault (mkLiteral "transparent");
      };

      button = {
        cursor = lib.mkDefault "pointer";
        border-radius = lib.mkForce (mkLiteral "1em");
        padding = lib.mkForce (mkLiteral "1em 1.5em");
        font = lib.mkForce "MartianMono Nerd Font 14";
        background-color = lib.mkForce (mkLiteral "@ocean-deep-teal");
        text-color = lib.mkForce (mkLiteral "@ocean-beige");
        border = lib.mkForce (mkLiteral "2px solid");
        border-color = lib.mkForce (mkLiteral "@ocean-deep-sapphire");
      };

      "button selected" = {
        background-color = lib.mkForce (mkLiteral "@ocean-bioluminescent");
        text-color = lib.mkForce (mkLiteral "@ocean-midnight");
        border-color = lib.mkForce (mkLiteral "@ocean-coral-blue");
      };

      # Search Input
      inputbar = {
        enabled = lib.mkForce true;
        spacing = lib.mkForce (mkLiteral "0em");
        padding = lib.mkForce (mkLiteral "0em 0em 2em 0em");
        children = lib.mkForce [ "entry" ];
        background-color = lib.mkDefault (mkLiteral "transparent");
        orientation = lib.mkForce (mkLiteral "horizontal");
      };

      entry = {
        enabled = lib.mkForce true;
        expand = lib.mkDefault true;
        cursor = lib.mkDefault (mkLiteral "text");
        placeholder = lib.mkForce "Search applications...";
        background-color = lib.mkForce (mkLiteral "@input-bg-darker");
        text-color = lib.mkForce (mkLiteral "@ocean-text");
        border-radius = lib.mkForce (mkLiteral "1.5em");
        border = lib.mkForce (mkLiteral "2px solid");
        border-color = lib.mkForce (mkLiteral "@ocean-deep-sapphire");
        padding = lib.mkForce (mkLiteral "1em 1.5em");
        height = lib.mkForce (mkLiteral "3em");
        font = lib.mkForce "MartianMono Nerd Font 14";
        placeholder-color = lib.mkForce (mkLiteral "@ocean-seafoam-gray");
      };

      # Listview
      listview = {
        enabled = lib.mkDefault true;
        spacing = lib.mkDefault (mkLiteral "0.3em");
        padding = lib.mkDefault (mkLiteral "1em");
        columns = lib.mkForce 1;
        lines = lib.mkForce 7;
        cycle = lib.mkDefault true;
        dynamic = lib.mkDefault true;
        scrollbar = lib.mkDefault false;
        layout = lib.mkForce (mkLiteral "vertical");
        reverse = lib.mkDefault false;
        expand = lib.mkDefault true;
        fixed-height = lib.mkDefault false;
        fixed-columns = lib.mkDefault true;
        cursor = lib.mkDefault "default";
        background-color = lib.mkDefault (mkLiteral "transparent");
      };

      # Standard Elements - Kleinere Darstellung
      element = {
        enabled = lib.mkDefault true;
        spacing = lib.mkForce (mkLiteral "1em");
        padding = lib.mkForce (mkLiteral "0.8em 1.2em");
        cursor = lib.mkDefault "pointer";
        background-color = lib.mkForce (mkLiteral "@element-bg");
        text-color = lib.mkForce (mkLiteral "@ocean-text-dim");
        border-radius = lib.mkForce (mkLiteral "0.8em");
        border = lib.mkForce (mkLiteral "1px solid");
        border-color = lib.mkForce (mkLiteral "@ocean-deep-sapphire");
        orientation = lib.mkForce (mkLiteral "horizontal");
        font = lib.mkForce "MartianMono Nerd Font 10";
      };

      # Ausgewähltes Element - Deutlich größer und prominenter
      "element selected.normal" = {
        background-color = lib.mkForce (mkLiteral "@ocean-coral-blue");
        text-color = lib.mkForce (mkLiteral "@ocean-beige");
        border-color = lib.mkForce (mkLiteral "@ocean-bioluminescent");
        border = lib.mkForce (mkLiteral "3px solid");
        border-radius = lib.mkForce (mkLiteral "1.5em");
        font = lib.mkForce ("MartianMono Nerd Font 16");
        padding = lib.mkForce (mkLiteral "1.8em 2.5em");
      };

      # Alternative Elemente für visuelle Variation
      "element alternate.normal" = {
        background-color = lib.mkForce (mkLiteral "@element-bg-alt");
        text-color = lib.mkForce (mkLiteral "@ocean-text-dim");
        font = lib.mkForce "MartianMono Nerd Font 9";
        padding = lib.mkForce (mkLiteral "0.6em 1em");
      };

      # Standard Icons
      element-icon = {
        size = lib.mkForce (mkLiteral "2em");
        cursor = lib.mkDefault (mkLiteral "inherit");
        background-color = lib.mkDefault (mkLiteral "transparent");
        text-color = lib.mkDefault (mkLiteral "inherit");
      };

      # Größere Icons für ausgewählte Elemente
      "element selected element-icon" = {
        size = lib.mkForce (mkLiteral "4em");
      };

      element-text = {
        vertical-align = lib.mkForce (mkLiteral "0.5");
        horizontal-align = lib.mkForce (mkLiteral "0.0");
        cursor = lib.mkDefault (mkLiteral "inherit");
        background-color = lib.mkDefault (mkLiteral "transparent");
        text-color = lib.mkDefault (mkLiteral "inherit");
      };

      # Error handling
      error-message = {
        padding = lib.mkForce (mkLiteral "2em");
        border-radius = lib.mkForce (mkLiteral "1em");
        background-color = lib.mkForce (mkLiteral "@ocean-coral-red");
        text-color = lib.mkForce (mkLiteral "@ocean-beige");
        children = lib.mkForce [ "textbox" ];
      };

      textbox = {
        text-color = lib.mkDefault (mkLiteral "inherit");
        vertical-align = lib.mkDefault (mkLiteral "0.5");
        horizontal-align = lib.mkDefault (mkLiteral "0.5");
        font = lib.mkForce "MartianMono Nerd Font 12";
      };

      # Ocean Theme Farben - Stylix basiert
      "*" = {
        # Hintergründe
        main-bg-darker = lib.mkDefault (mkLiteral "#202d36e0"); # base00 mit Transparenz
        input-bg-darker = lib.mkDefault (mkLiteral "#1d4d4fc0"); # base07 mit Transparenz
        element-bg = lib.mkDefault (mkLiteral "#141e2680"); # base01 mit Transparenz
        element-bg-alt = lib.mkDefault (mkLiteral "#004d6650"); # base04 mit Transparenz

        # Original Ocean Palette aus Stylix
        ocean-midnight = lib.mkDefault (mkLiteral "#202d36"); # base00
        ocean-abyss = lib.mkDefault (mkLiteral "#141e26"); # base01
        ocean-kelp = lib.mkDefault (mkLiteral "#1d4d4f"); # base07
        ocean-deep-teal = lib.mkDefault (mkLiteral "#006666"); # base0A
        ocean-coral-blue = lib.mkDefault (mkLiteral "#0088cc"); # base03
        ocean-bioluminescent = lib.mkDefault (mkLiteral "#00c2c2"); # base0B
        ocean-sea-foam = lib.mkDefault (mkLiteral "#2d8a8a"); # base0C
        ocean-deep-sapphire = lib.mkDefault (mkLiteral "#004d66"); # base04
        ocean-text = lib.mkDefault (mkLiteral "#e6f3f7"); # base06
        ocean-text-dim = lib.mkDefault (mkLiteral "#a3b8c2"); # base0F
        ocean-beige = lib.mkDefault (mkLiteral "#ffcc99"); # base05
        ocean-coral-red = lib.mkDefault (mkLiteral "#ff4500"); # base08
        ocean-seafoam-gray = lib.mkDefault (mkLiteral "#a3b8c2"); # base0F
        ocean-marine-blue = lib.mkDefault (mkLiteral "#006bb3"); # base0D
      };
    };
  };

  # Stylix wallpaper setup
  systemd.user.services.rofi-wallpaper-sync = {
    Unit = {
      Description = "Sync Stylix wallpaper for Rofi";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "rofi-wallpaper-sync" ''
        WALL_DIR="${wallpaperPath}"
        mkdir -p "$WALL_DIR"

        # Copy current stylix wallpaper
        STYLIX_WALL="${stylixWallpaper}"

        # Create thumbnail
        ${pkgs.imagemagick}/bin/convert "$STYLIX_WALL" \
          -resize 2560x1440^ -gravity center -extent 2560x1440 \
          "$WALL_DIR/current-thumb.jpg"

        # Create blurred version
        ${pkgs.imagemagick}/bin/convert "$STYLIX_WALL" \
          -resize 2560x1440^ -gravity center -extent 2560x1440 \
          -blur 0x4 \
          "$WALL_DIR/current-blur.jpg"
      '';
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Ensure cache directory exists
  home.file."${wallpaperPath}/.keep".text = "";

  # Keybindings für Hyprland
  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, R, exec, rofi -show drun"
  ];
}
