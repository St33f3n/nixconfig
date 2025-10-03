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
      general = {
        # Window Management
        resize_on_border = true;
        extend_border_grab_area = 15;
        no_focus_fallback = true;
        allow_tearing = false;

        # Layout & Spacing - Reduced gaps
        gaps_in = 3; # Back to your original, compact spacing
        gaps_out = 6; # Minimal outer gaps
        border_size = 2;

        # Border Colors - Coral orange active, morandi green inactive
        "col.active_border" = lib.mkForce "rgb(ff6347)"; # coral_orange
        "col.inactive_border" = lib.mkForce "rgba(6b8e6b66)"; # sea_foam (morandi green) with transparency

        # Snapping & Tiling
        snap = {
          enabled = true;
          window_gap = 3; # Match gaps_in
          monitor_gap = 6; # Match gaps_out
        };

        # Layout behavior
        layout = "dwindle";
      };
      dwindle = {
        pseudotile = false;
        preserve_split = true; # Behält Split-Richtungen bei
        smart_split = false;
        smart_resizing = true;

        # Ultrawide-spezifische Optimierungen
        force_split = 2; # Neue Fenster immer rechts/unten
        split_width_multiplier = 1.6; # Angepasst für 32:9 Verhältnis
        use_active_for_splits = true; # Nutzt aktives Fenster statt Maus

        # Verhältnisse und Größen
        default_split_ratio = 1.0; # Gleichmäßige 50/50 Splits
        split_bias = 0; # Split-Bias auf direktional

        # Spezielle Workspace-Skalierung
        special_scale_factor = 0.8;

        # Einzelfenster-Optimierung für Ultrawide
        single_window_aspect_ratio = "16 9"; # 16:9 für einzelne Fenster
        single_window_aspect_ratio_tolerance = 0.1;
      };
      cursor = {
        zoom_factor = 1;
        zoom_rigid = false;
      };

      bind = [
        #Applications
        "$mainMod, RETURN, exec, alacritty"
        "$mainMod, B, exec, librewolf"
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
        "$mainMod, code:87, workspace, 11"
        "$mainMod, code:88, workspace, 12"
        "$mainMod, code:89, workspace, 13"
        "$mainMod, code:83, workspace, 14"
        "$mainMod, code:84, workspace, 15"
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
        "desc:Samsung Electric Company C49RG9x H1AK500000,5120x1440@120,0x0,1"
        "desc:Ancor Communications Inc VE228 C7LMQS030933,preferred,-1980x0,1"
        "desc:Samsung Electric Company LS32DG30X H8CX600213,1920x1080@60,5120x0,1"
        "eDP-1,2560x1600@60,0x0,1"
        "Virtual-1,1920x1080@60,0x0,1" # VM Monitor
        ",preferred,auto,1"
      ];

      exec-once = [
        #        "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all"
        "[workspace 1 silent] librewolf"
        "[workspace 2 silent] trilium"
        "[workspace 3 silent] vesktop"
        "[workspace 4 silent] "
        "[workspace 5 silent] "
        "wl-paste --watch cliphist store"
        "[workspace 6 silent] spotify"
        "[workspace 7 silent] podman-desktop"
        "[workspace 12 silent] nextcloud-talk-desktop"
        "[workspace 13 silent] vorta"
        "[workspace 15 silent] sleep 10;nextcloud"
        "[workspace 15 silent] alacritty -e protonmail-bridge --cli"
        "[workspace 11 silent] eu.betterbird.Betterbird"
        "[workspace 14 silent] localsend_app"
        "[workspace 14 silent] distrobox enter python_box"
      ];
      env = [
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XCURSOR_THEME,Qogir-Dark"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "MOZ_ENABLE_WAYLAND,1"
        "XWAYLAND_FORCE_SCALE,1"
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

        # Curves
        bezier = [
          "expressiveFastSpatial, 0.42, 1.67, 0.21, 0.90"
          "expressiveSlowSpatial, 0.39, 1.29, 0.35, 0.98"
          "expressiveDefaultSpatial, 0.38, 1.21, 0.22, 1.00"
          "emphasizedDecel, 0.05, 0.7, 0.1, 1"
          "emphasizedAccel, 0.3, 0, 0.8, 0.15"
          "standardDecel, 0, 0, 0, 1"
          "menu_decel, 0.1, 1, 0, 1"
          "menu_accel, 0.52, 0.03, 0.72, 0.08"
        ];

        # Configs
        animation = [
          # windows
          "windowsIn, 1, 3, emphasizedDecel, popin 80%"
          "windowsOut, 1, 2, emphasizedDecel, popin 90%"
          "windowsMove, 1, 3, emphasizedDecel, slide"
          "border, 1, 10, emphasizedDecel"
          # layers
          "layersIn, 1, 2.7, emphasizedDecel, popin 93%"
          "layersOut, 1, 2.4, menu_accel, popin 94%"
          # fade
          "fadeLayersIn, 1, 0.5, menu_decel"
          "fadeLayersOut, 1, 2.7, menu_accel"
          # workspaces
          "workspaces, 1, 7, menu_decel, slide"
          # specialWorkspace
          "specialWorkspaceIn, 1, 2.8, emphasizedDecel, slidevert"
          "specialWorkspaceOut, 1, 1.2, emphasizedAccel, slidevert"
        ];
      };

      workspace = [
        "1, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "2, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "3, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "4, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "5, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "6, monitor:desc:Samsung Electric Company LS32DG30X H8CX600213, default:true"
        "7, monitor:desc:Samsung Electric Company LS32DG30X H8CX600213, default:true"
        "8, monitor:desc:Samsung Electric Company LS32DG30X H8CX600213, default:true"
        "9, monitor:desc:Samsung Electric Company LS32DG30X H8CX600213, default:true"
        "10, monitor:desc:Samsung Electric Company LS32DG30X H8CX600213, default:true"

        "11, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "12, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "13, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "14, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "15, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"

      ];

      windowrulev2 = [
        # Workspace Rules - für deine installierten Apps
        "workspace 4,class:^(vesktop)$" # Discord client
        "workspace 8 silent,class:^(com.borgbase.Vorta)$" # Backup tool (Vorta)
        "workspace 7 silent,class:^(org.keepassxc.KeePassXC)$" # KeePassXC

        # Float Rules - für deine Apps
        "float,title:^(About Mozilla Firefox)$"
        "float,class:^(firefox)$,title:^(Picture-in-Picture)$"
        "float,class:^(firefox)$,title:^(Library)$"
        "float,class:^(Alacritty)$,title:^(btop)$" # btop floating
        "float,class:^(Alacritty)$,title:^(fastfetch)$" # fastfetch floating
        "float,class:^(qt5ct)$" # Qt5 Settings floating
        "float,class:^(qt6ct)$" # Qt6 Settings floating
        "float,class:^(kvantummanager)$" # Kvantum floating
        "float,class:^(org.pulseaudio.pavucontrol)$"
        "float,class:^(blueman-manager)$"
        "float,class:^(nm-connection-editor)$"
        "float,class:^(org.kde.polkit-kde-authentication-agent-1)$"
      ];

      # Standard File Dialogs - universell relevant
      windowrule = [
        "float,title:^(Open)$"
        "float,title:^(Choose Files)$"
        "float,title:^(Save As)$"
        "float,title:^(Confirm to replace files)$"
        "float,title:^(File Operation Progress)$"
      ];

      # Layer Rules - für Rofi und Notifications
      layerrule = [
        "blur,rofi"
        "ignorezero,rofi"
        "blur,notifications"
        "ignorezero,notifications"
      ];
      misc = {
        vrr = 0;
        vfr = 0;
        anr_missed_pings = 15;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        allow_session_lock_restore = true;
        focus_on_activate = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
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
