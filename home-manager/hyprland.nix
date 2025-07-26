{ lib, config, pkgs, inputs, ... }:
let
in {
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
        "eDP-1,2560x1600@60,0x0,1"
        ",preferred,auto,1"
      ];

      exec-once =
        [ "[workspace 3 silent] webcord" "[workspace 5 silent] nextcloud" "wl-paste --watch cliphist store" "[workspace 2 silent] keepassxc"];
      env = [ "ELECTRON_OZONE_PLATFORM_HINT,auto"
      "XCURSOR_THEME,Qogir-dark"
      "XCURSOR_SIZE,24"];
      input = {
        "kb_layout" = "de";
        "numlock_by_default" = "true";
        "mouse_refocus" = "false";
        "follow_mouse" = "1";
        touchpad = { "middle_button_emulation" = "true"; };
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
