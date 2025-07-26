{ config, pkgs, ... }: 
let
  inherit (config.lib.formats.rasi) mkLiteral;
  
  # Stylix wallpaper integration
  wallpaperPath = "${config.home.homeDirectory}/.cache/rofi-wallpapers";
  # Use the same wallpaper as stylix
  stylixWallpaper = config.stylix.image;
in {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    
    extraConfig = {
      modi = "drun,filebrowser,window,run";
      show-icons = true;
      display-drun = " ";
      display-run = " ";
      display-filebrowser = " ";
      display-window = " ";
      drun-display-format = "{name}";
      window-format = "{w}{t}";
      font = "MartianMono Nerd Font 10";
      icon-theme = "Qogir-Dark";
    };
    
    theme = {
      # Main Window
      window = {
        height = mkLiteral "33em";
        width = mkLiteral "63em";
        transparency = "real";
        fullscreen = false;
        enabled = true;
        cursor = "default";
        spacing = mkLiteral "0em";
        padding = mkLiteral "0em";
        border-color = mkLiteral "@main-br";
        background-color = mkLiteral "@main-bg";
      };

      mainbox = {
        enabled = true;
        spacing = mkLiteral "0em";
        padding = mkLiteral "0em";
        orientation = mkLiteral "horizontal";
        children = [ "dummywall" "listbox" ];
        background-color = mkLiteral "transparent";
      };

      dummywall = {
        spacing = mkLiteral "0em";
        padding = mkLiteral "0em";
        width = mkLiteral "37em";
        expand = false;
        orientation = mkLiteral "horizontal";
        children = [ "mode-switcher" "inputbar" ];
        background-color = mkLiteral "transparent";
        background-image = mkLiteral "url(\"${wallpaperPath}/current-thumb.jpg\", height)";
      };

      # Mode Switcher
      mode-switcher = {
        orientation = mkLiteral "vertical";
        enabled = true;
        width = mkLiteral "3.8em";
        padding = mkLiteral "9.2em 0.5em 9.2em 0.5em";
        spacing = mkLiteral "1.2em";
        background-color = mkLiteral "transparent";
        background-image = mkLiteral "url(\"${wallpaperPath}/current-blur.jpg\", height)";
      };

      button = {
        cursor = "pointer";
        border-radius = mkLiteral "2em";
        background-color = mkLiteral "@main-bg";
        text-color = mkLiteral "@main-fg";
      };

      "button selected" = {
        background-color = mkLiteral "@main-fg";
        text-color = mkLiteral "@main-bg";
      };

      # Input - Fuzzy Search Textzeile
      inputbar = {
        enabled = true;
        spacing = mkLiteral "0.5em";
        padding = mkLiteral "1em 1em 0.5em 1em";
        children = [ "textbox-prompt" "entry" ];
        background-color = mkLiteral "transparent";
      };

      "textbox-prompt" = {
        expand = false;
        str = " Search:";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@main-fg";
      };

      entry = {
        enabled = true;
        expand = true;
        cursor = mkLiteral "text";
        placeholder = "Type to search...";
        placeholder-color = mkLiteral "@main-fg80";
        background-color = mkLiteral "@input-bg";
        text-color = mkLiteral "@main-fg";
        border-radius = mkLiteral "0.5em";
        padding = mkLiteral "0.3em 0.8em";
      };

      # Lists
      listbox = {
        spacing = mkLiteral "0em";
        padding = mkLiteral "2em";
        children = [ "dummy" "listview" "dummy" ];
        background-color = mkLiteral "transparent";
      };

      listview = {
        enabled = true;
        spacing = mkLiteral "0em";
        padding = mkLiteral "0em";
        columns = 1;
        lines = 8;
        cycle = true;
        dynamic = true;
        scrollbar = false;
        layout = mkLiteral "vertical";
        reverse = false;
        expand = false;
        fixed-height = true;
        fixed-columns = true;
        cursor = "default";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@main-fg";
      };

      dummy = {
        background-color = mkLiteral "transparent";
      };

      # Elements
      element = {
        enabled = true;
        spacing = mkLiteral "0.8em";
        padding = mkLiteral "0.4em 0.4em 0.4em 1.5em";
        cursor = "pointer";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@main-fg";
      };

      "element selected.normal" = {
        background-color = mkLiteral "@select-bg";
        text-color = mkLiteral "@select-fg";
      };

      element-icon = {
        size = mkLiteral "2.8em";
        cursor = mkLiteral "inherit";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
      };

      element-text = {
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.0";
        cursor = mkLiteral "inherit";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
      };

      # Error handling
      error-message = {
        text-color = mkLiteral "@main-fg";
        background-color = mkLiteral "@main-bg";
        text-transform = mkLiteral "capitalize";
        children = [ "textbox" ];
      };

      textbox = {
        text-color = mkLiteral "inherit";
        background-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.5";
      };

      # Color scheme - Ocean Theme
      "*" = {
        main-bg = mkLiteral "#202d36E6";      # midnight mit transparency
        main-fg = mkLiteral "#e6f3f7";        # text_primary
        main-fg80 = mkLiteral "#e6f3f780";    # text_primary transparent
        main-br = mkLiteral "#1d4d4f";        # kelp_green
        main-ex = mkLiteral "#263440";        # surface
        select-bg = mkLiteral "#0088cc80";    # coral_blue mit transparency
        select-fg = mkLiteral "#e6f3f7";      # text_primary
        input-bg = mkLiteral "#1d4d4f40";     # kelp_green transparent für Input
      };
    };
  };

  # Stylix wallpaper setup für Rofi
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
        
        # Create thumbnail (smaller for background)
        ${pkgs.imagemagick}/bin/convert "$STYLIX_WALL" \
          -resize 1920x1080^ -gravity center -extent 1920x1080 \
          "$WALL_DIR/current-thumb.jpg"
        
        # Create blurred version for mode switcher
        ${pkgs.imagemagick}/bin/convert "$STYLIX_WALL" \
          -resize 1920x1080^ -gravity center -extent 1920x1080 \
          -blur 0x8 "$WALL_DIR/current-blur.jpg"
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
    "$mainMod SHIFT, R, exec, rofi -show run"
    "$mainMod, TAB, exec, rofi -show window"
    "$mainMod CTRL, R, exec, rofi -show filebrowser"
  ];
}
