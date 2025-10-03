{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Generate native niri config.kdl with correct KDL syntax
  home.file.".config/niri/config.kdl".text = ''
    // Input configuration - flags are used without values
    input {
        keyboard {
            xkb {
                layout "de"
                options "caps:escape"
            }
            numlock
        }
        
        mouse {
            accel-speed 0.0
            accel-profile "flat"
        }
        
        touchpad {
            tap
            dwt
            natural-scroll
            click-method "clickfinger"
            scroll-method "two-finger"
        }
    }

    // Outputs - using string mode format
    output "Samsung Electric Company C49RG9x H1AK500000" {
        mode "5120x1440@120"
        position x=0 y=0
        scale 1.066
    }

    output "Ancor Communications Inc VE228 C7LMQS030933" {
        position x=-1980 y=0
        scale 1.0
    }

    output "PNP(AOC) U2868 0x00000656" {
        mode "3840x2160@60"
        position x=4178 y=-500
        scale 2.0
        transform "90"
    }

    output "eDP-1" {
        mode "2560x1600@60"
        position x=0 y=0
        scale 1.0
    }

    output "Virtual-1" {
        mode "1920x1080@60"
        position x=0 y=0
        scale 1.0
    }

    overview{
        zoom 0.3
    }

    // Layout configuration
    layout {
        gaps 12
        center-focused-column "on-overflow"
        
        preset-column-widths {
            proportion 1.0
            proportion 0.67
            proportion 0.5
            proportion 0.33
            fixed 400
            fixed 600
        }
        
        default-column-width {
            proportion 0.5
        }
        
        focus-ring {
            width 3
            active-color "#2d8a8a"
            inactive-color "#1d4d4f"
        }
        
        border {
            width 2
            active-color "#ff6347"
            inactive-color "#202d36"
        }
    }

    // Startup applications - each spawn on separate line
    spawn-at-startup "swaybg" "-i" "${config.stylix.image}" "-m" "fill"
    spawn-at-startup "zen"
    spawn-at-startup "keepassxc"
    spawn-at-startup "vesktop"
    spawn-at-startup "nextcloud"
    spawn-at-startup "spotify"

    // Window rules - workspaces must be strings
    window-rule {
        match app-id="zen"
        open-on-workspace "1"
        default-column-width { proportion 0.8; }
    }

    window-rule {
        match app-id="org.keepassxc.KeePassXC"
        open-on-workspace "2"
        default-column-width { proportion 0.6; }
    }

    window-rule {
        match app-id="vesktop"
        open-on-workspace "3"
        default-column-width { proportion 0.7; }
    }

    window-rule {
        match app-id="Spotify"
        open-on-workspace "6"
        default-column-width { proportion 0.8; }
    }

    window-rule {
        match app-id="nextcloud"
        open-on-workspace "7"
        default-column-width { proportion 0.6; }
    }

    window-rule {
        match title="Picture-in-Picture"
        default-column-width { fixed 400; }
    }

    window-rule {
        match app-id="org.pulseaudio.pavucontrol"
        default-column-width { fixed 500; }
    }

    window-rule {
        match app-id="blueman-manager"
        default-column-width { fixed 600; }
    }

    // Animations - using valid curves only
    animations {
        slowdown 1.0
        window-open {
            duration-ms 250
            curve "ease-out-expo"
        }
        window-close {
            duration-ms 200
            curve "ease-out-quad"
        }
        workspace-switch {
            duration-ms 300
            curve "ease-out-quad"
        }
        window-movement {
            duration-ms 200
            curve "ease-out-quad"
        }
    }

    // Keybindings - using correct action names
    binds {
        "Mod+Return" { spawn "alacritty"; }
        "Mod+B" { spawn "zen"; }
        "Mod+Period" { spawn "emote"; }
        "Mod+O" { spawn "trilium"; }
        "Mod+E" { spawn "alacritty" "-e" "yazi"; }
        "Mod+R" { spawn "rofi" "-show" "drun"; }

        "Mod+Q" { close-window; }
        "Mod+T" { fullscreen-window; }
        "Mod+F" { toggle-window-floating; }
        "Mod+J" { switch-preset-window-height; }

        "Mod+Left" { focus-column-left; }
        "Mod+Right" { focus-column-right; }
        "Mod+Up" { focus-window-up; }
        "Mod+Down" { focus-window-down; }

        "Mod+Ctrl+Left" { move-column-left; }
        "Mod+Ctrl+Right" { move-column-right; }
        "Mod+Ctrl+Up" { move-window-up; }
        "Mod+Ctrl+Down" { move-window-down; }

        "Mod+Shift+Right" { set-column-width "+10%"; }
        "Mod+Shift+Left" { set-column-width "-10%"; }
        "Mod+Shift+Up" { set-window-height "+10%"; }
        "Mod+Shift+Down" { set-window-height "-10%"; }

        "Mod+1" { focus-workspace 1; }
        "Mod+2" { focus-workspace 2; }
        "Mod+3" { focus-workspace 3; }
        "Mod+4" { focus-workspace 4; }
        "Mod+5" { focus-workspace 5; }
        "Mod+6" { focus-workspace 6; }
        "Mod+7" { focus-workspace 7; }
        "Mod+8" { focus-workspace 8; }
        "Mod+9" { focus-workspace 9; }
        "Mod+0" { focus-workspace 10; }

        "Mod+Shift+1" { move-column-to-workspace 1; }
        "Mod+Shift+2" { move-column-to-workspace 2; }
        "Mod+Shift+3" { move-column-to-workspace 3; }
        "Mod+Shift+4" { move-column-to-workspace 4; }
        "Mod+Shift+5" { move-column-to-workspace 5; }
        "Mod+Shift+6" { move-column-to-workspace 6; }
        "Mod+Shift+7" { move-column-to-workspace 7; }
        "Mod+Shift+8" { move-column-to-workspace 8; }
        "Mod+Shift+9" { move-column-to-workspace 9; }
        "Mod+Shift+0" { move-column-to-workspace 10; }

        "Mod+WheelScrollDown" { focus-workspace-down; }
        "Mod+WheelScrollUp" { focus-workspace-up; }

        "Mod+Tab" { focus-workspace-previous; }
        
        "Mod+W" { switch-preset-column-width; }
        "Mod+Shift+F" { maximize-column; }
        "Mod+Comma" { consume-window-into-column; }
        "Mod+Shift+Comma" { expel-window-from-column; }
        "Mod+BracketLeft" { consume-or-expel-window-left; }
        "Mod+BracketRight" { consume-or-expel-window-right; }

        "Mod+Shift+E" { quit; }
    }

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    cursor {
        xcursor-theme "Qogir-Dark"
        xcursor-size 24
    }
  '';

  # Environment variables for Wayland/Niri
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
    WAYLAND_DISPLAY = "wayland-0";

    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    GDK_SCALE = "1";

    XCURSOR_THEME = "Qogir-Dark";
    XCURSOR_SIZE = "24";
  };

  home.packages = with pkgs; [
    swaybg
  ];
}
