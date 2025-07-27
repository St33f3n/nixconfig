{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      # key bindings

      #Variabels
      "$mainMod" = "SUPER";

      bind = [
        #Applications
        "$mainMod, RETURN, exec, alacritty"
        "$mainMod, B, exec, zen"
        "$mainMod, period, exec, emote"
        "$mainMod, O, exec, trilium"
        "$mainMod, E, exec, alacritty -e yazi"

        #Windows
        "$mainMod, Q, killactive"
        "$mainMod, T, fullscreen"
        "$mainMod, F, togglefloating"
        "$mainMod, J, togglesplit"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod SHIFT, right, resizeactive, 100 0"
        "$mainMod SHIFT, left, resizeactive, -100 0"
        "$mainMod SHIFT, up, resizeactive, 0 -100"
        "$mainMod SHIFT, down, resizeactive, 0 100"
        #Workspaces

        # Workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod CTRL, down, workspace, empty"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      monitor = [
        "desc:Samsung Electric Company C49RG9x H1AK500000,5120x1440@120,0x0,1.066"
        "desc:Ancor Communications Inc VE228 C7LMQS030933,preferred,-1980x0,1"
        "desc:AOC U2868 0x00000656,3840x2160@60,4178x-500,2,transform,1"
        "eDP-1,2560x1600@60,0x0,1"
        "Virtual-1,1920x1080@60,0x0,1" # VM Monitor
        ",preferred,auto,1"
      ];

      exec-once = [
        "[workspace 3 silent] vesktop"
        "[workspace 7 silent] nextcloud"
        "wl-paste --watch cliphist store"
        "[workspace 2 silent] keepassxc"
        "[workspace 6 silent] spotify"
        "[workspace 1 silent] zen"
      ];
      env = [
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XCURSOR_THEME,Qogir-Dark"
        #"AQ_DRM_DEVICES,/dev/dri/card0:/dev"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "MOZ_ENABLE_WAYLAND,1"
        "GDK_SCALE,1"
        "XCURSOR_SIZE,24"
      ];
      input = {
        "kb_layout" = "de";
        "numlock_by_default" = "true";
        "mouse_refocus" = "false";
        "follow_mouse" = "1";
        touchpad = {
          "middle_button_emulation" = "true";
        };
        sensitivity = 0;
      };
      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      workspace = [
        "1, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "2, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "3, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"

        "6, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "7, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "8, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "9, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "10, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "5, monitor:desc:AOC U2868 0x00000656, default:true"
        "4, monitor:desc:AOC U2868 0x00000656, default:true"

      ];

      misc = {
        vrr = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          new_optimizations = "on";
          ignore_opacity = true;
          xray = true;
        };
        shadow = {
          enabled = true;
          range = 30;
          render_power = 3;
        };
        active_opacity = 1.0;
        inactive_opacity = 0.98;
        fullscreen_opacity = 1.0;
        dim_inactive = true;
        dim_strength = 0.1;
      };
    };
  };
}
