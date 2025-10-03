{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    
    settings = {
      # ════════════════════════════════════════════════════════════════════════
      # VARIABLES
      # ════════════════════════════════════════════════════════════════════════
      "$mainMod" = "SUPER";

      # ════════════════════════════════════════════════════════════════════════
      # MONITOR CONFIGURATION
      # ════════════════════════════════════════════════════════════════════════
      monitor = [
        "desc:Samsung Electric Company C49RG9x H1AK500000,5120x1440@120,0x0,1"
        "desc:Ancor Communications Inc VE228 C7LMQS030933,preferred,-1980x0,1"
        "desc:Samsung Electric Company LS32DG30X H8CX600213,1920x1080@60,5120x0,1"
        "eDP-1,2560x1600@60,0x0,1"
        "Virtual-1,1920x1080@60,0x0,1" # VM Monitor
        ",preferred,auto,1"
      ];

      # ════════════════════════════════════════════════════════════════════════
      # WORKSPACE ASSIGNMENT
      # ════════════════════════════════════════════════════════════════════════
      workspace = [
        # Main Ultrawide Monitor (C49RG9x) - Workspaces 1-5
        "1, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "2, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "3, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "4, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        "5, monitor:desc:Samsung Electric Company C49RG9x H1AK500000, default:true"
        
        # Secondary Monitor (LS32DG30X) - Workspaces 6-10
        "6, monitor:desc:Samsung Electric Company LS32DG30X H8CX600213, default:true"
        "7, monitor:desc:Samsung Electric Company LS32DG30X H8CX600213, default:true"
        "8, monitor:desc:Samsung Electric Company LS32DG30X H8CX600213, default:true"
        "9, monitor:desc:Samsung Electric Company LS32DG30X H8CX600213, default:true"
        "10, monitor:desc:Samsung Electric Company LS32DG30X H8CX600213, default:true"

        # Vertical Monitor (VE228) - Workspaces 11-15
        "11, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "12, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "13, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "14, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
        "15, monitor:desc:Ancor Communications Inc VE228 C7LMQS030933, default:true"
      ];

      # ════════════════════════════════════════════════════════════════════════
      # INPUT CONFIGURATION
      # ════════════════════════════════════════════════════════════════════════
      input = {
        kb_layout = "de";
        numlock_by_default = true;
        mouse_refocus = false;
        follow_mouse = 1;
        
        touchpad = {
          middle_button_emulation = true;
        };
        
        sensitivity = 0;
      };

      # ════════════════════════════════════════════════════════════════════════
      # GENERAL WINDOW MANAGEMENT
      # ════════════════════════════════════════════════════════════════════════
      general = {
        # ────────────────────────────────────────────────────────────────────────
        # Window Interaction
        # ────────────────────────────────────────────────────────────────────────
        resize_on_border = true;
        extend_border_grab_area = 15;
        no_focus_fallback = true;
        allow_tearing = false;

        # ────────────────────────────────────────────────────────────────────────
        # Layout & Spacing
        # ────────────────────────────────────────────────────────────────────────
        gaps_in = 3;
        gaps_out = 6;
        border_size = 2;

        # ────────────────────────────────────────────────────────────────────────
        # Border Colors
        # ────────────────────────────────────────────────────────────────────────
        "col.active_border" = lib.mkForce "rgb(ff6347)"; # Coral orange
        "col.inactive_border" = lib.mkForce "rgba(6b8e6b66)"; # Sea foam (morandi green)

        # ────────────────────────────────────────────────────────────────────────
        # Snapping & Tiling
        # ────────────────────────────────────────────────────────────────────────
        snap = {
          enabled = true;
          window_gap = 3;
          monitor_gap = 6;
        };

        layout = "dwindle";
      };

      # ════════════════════════════════════════════════════════════════════════
      # DWINDLE LAYOUT (Ultrawide Optimized)
      # ════════════════════════════════════════════════════════════════════════
      dwindle = {
        pseudotile = false;
        preserve_split = true;
        smart_split = false;
        smart_resizing = true;

        # ────────────────────────────────────────────────────────────────────────
        # Ultrawide-Specific Settings (32:9)
        # ────────────────────────────────────────────────────────────────────────
        force_split = 2;
        split_width_multiplier = 1.6;
        use_active_for_splits = true;
        default_split_ratio = 1.0;
        split_bias = 0;

        # ────────────────────────────────────────────────────────────────────────
        # Special Window Handling
        # ────────────────────────────────────────────────────────────────────────
        special_scale_factor = 0.8;
        single_window_aspect_ratio = "16 9";
        single_window_aspect_ratio_tolerance = 0.1;
      };

      # ════════════════════════════════════════════════════════════════════════
      # CURSOR SETTINGS
      # ════════════════════════════════════════════════════════════════════════
      cursor = {
        zoom_factor = 1;
        zoom_rigid = false;
      };

      # ════════════════════════════════════════════════════════════════════════
      # DECORATIONS
      # ════════════════════════════════════════════════════════════════════════
      decoration = {
        rounding = 10;
        
        # ────────────────────────────────────────────────────────────────────────
        # Blur Settings
        # ────────────────────────────────────────────────────────────────────────
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          new_optimizations = "on";
          ignore_opacity = true;
          xray = true;
        };
        
        # ────────────────────────────────────────────────────────────────────────
        # Shadow Settings
        # ────────────────────────────────────────────────────────────────────────
        shadow = {
          enabled = true;
          range = 30;
          render_power = 3;
        };
        
        # ────────────────────────────────────────────────────────────────────────
        # Opacity Settings
        # ────────────────────────────────────────────────────────────────────────
        active_opacity = 1.0;
        inactive_opacity = 0.98;
        fullscreen_opacity = 1.0;
        dim_inactive = true;
        dim_strength = 0.1;
      };

      # ════════════════════════════════════════════════════════════════════════
      # ANIMATIONS
      # ════════════════════════════════════════════════════════════════════════
      animations = {
        enabled = true;

        # ────────────────────────────────────────────────────────────────────────
        # Bezier Curves
        # ────────────────────────────────────────────────────────────────────────
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

        # ────────────────────────────────────────────────────────────────────────
        # Animation Definitions
        # ────────────────────────────────────────────────────────────────────────
        animation = [
          # Windows
          "windowsIn, 1, 3, emphasizedDecel, popin 80%"
          "windowsOut, 1, 2, emphasizedDecel, popin 90%"
          "windowsMove, 1, 3, emphasizedDecel, slide"
          "border, 1, 10, emphasizedDecel"
          
          # Layers
          "layersIn, 1, 2.7, emphasizedDecel, popin 93%"
          "layersOut, 1, 2.4, menu_accel, popin 94%"
          
          # Fade
          "fadeLayersIn, 1, 0.5, menu_decel"
          "fadeLayersOut, 1, 2.7, menu_accel"
          
          # Workspaces
          "workspaces, 1, 7, menu_decel, slide"
          
          # Special Workspace
          "specialWorkspaceIn, 1, 2.8, emphasizedDecel, slidevert"
          "specialWorkspaceOut, 1, 1.2, emphasizedAccel, slidevert"
        ];
      };

      # ════════════════════════════════════════════════════════════════════════
      # MISCELLANEOUS
      # ════════════════════════════════════════════════════════════════════════
      misc = {
        vrr = 1;  # Variable Refresh Rate aktiviert
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

      # ════════════════════════════════════════════════════════════════════════
      # ENVIRONMENT VARIABLES
      # ════════════════════════════════════════════════════════════════════════
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

      # ════════════════════════════════════════════════════════════════════════
      # KEY BINDINGS
      # ════════════════════════════════════════════════════════════════════════
      bind = [
        # ────────────────────────────────────────────────────────────────────────
        # Application Launchers
        # ────────────────────────────────────────────────────────────────────────
        "$mainMod, RETURN, exec, alacritty"
        "$mainMod, B, exec, librewolf"
        "$mainMod, R, exec, rofi -show drun"
        "$mainMod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$mainMod, period, exec, emote"
        "$mainMod, O, exec, trilium"
        "$mainMod, E, exec, alacritty -e yazi"

        # ────────────────────────────────────────────────────────────────────────
        # Window Management
        # ────────────────────────────────────────────────────────────────────────
        "$mainMod, Q, killactive"
        "$mainMod, T, fullscreen"
        "$mainMod, F, togglefloating"
        "$mainMod, J, togglesplit"
        "$mainMod, P, pin"  # Pin window to all workspaces
        
        # Window Focus
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        
        # Window Resize
        "$mainMod SHIFT, right, resizeactive, 100 0"
        "$mainMod SHIFT, left, resizeactive, -100 0"
        "$mainMod SHIFT, up, resizeactive, 0 -100"
        "$mainMod SHIFT, down, resizeactive, 0 100"

        # ────────────────────────────────────────────────────────────────────────
        # Workspace Navigation (1-10)
        # ────────────────────────────────────────────────────────────────────────
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
        
        # ────────────────────────────────────────────────────────────────────────
        # Workspace Navigation (11-15) - Numpad
        # ────────────────────────────────────────────────────────────────────────
        "$mainMod, code:87, workspace, 11"  # KP_1
        "$mainMod, code:88, workspace, 12"  # KP_2
        "$mainMod, code:89, workspace, 13"  # KP_3
        "$mainMod, code:83, workspace, 14"  # KP_4
        "$mainMod, code:84, workspace, 15"  # KP_5

        # ────────────────────────────────────────────────────────────────────────
        # Move Window to Workspace
        # ────────────────────────────────────────────────────────────────────────
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
        
        # ────────────────────────────────────────────────────────────────────────
        # Workspace Scrolling & Special
        # ────────────────────────────────────────────────────────────────────────
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod CTRL, down, workspace, empty"
        
        # Scratchpad (Yakuake-style)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
      ];

      # ════════════════════════════════════════════════════════════════════════
      # MOUSE BINDINGS
      # ════════════════════════════════════════════════════════════════════════
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # ════════════════════════════════════════════════════════════════════════
      # MEDIA KEY BINDINGS (Locked - work even when locked)
      # ════════════════════════════════════════════════════════════════════════
      bindl = [
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # ════════════════════════════════════════════════════════════════════════
      # VOLUME BINDINGS (Locked + Repeat)
      # ════════════════════════════════════════════════════════════════════════
      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      # ════════════════════════════════════════════════════════════════════════
      # WINDOW RULES V2
      # ════════════════════════════════════════════════════════════════════════
      windowrulev2 = [
        # ────────────────────────────────────────────────────────────────────────
        # Special Workspace - Yakuake-style Scratchpad
        # ────────────────────────────────────────────────────────────────────────
        "float,class:^(scratchpad)$"
        "size 100% 50%,class:^(scratchpad)$"
        "move 0 0,class:^(scratchpad)$"
        "animation slide,class:^(scratchpad)$"
        
        # ────────────────────────────────────────────────────────────────────────
        # Workspace Assignment
        # ────────────────────────────────────────────────────────────────────────
        "workspace 7,class:^(vesktop)$"
        "workspace 7,class:^(com.github.IsmaelMartinez.teams_for_linux)$"  # Nextcloud Talk
        "workspace 13 silent,class:^(com.borgbase.Vorta)$"

        # ────────────────────────────────────────────────────────────────────────
        # Floating Windows - Librewolf/Firefox
        # ────────────────────────────────────────────────────────────────────────
        "float,title:^(About LibreWolf)$"
        "float,class:^(librewolf)$,title:^(Picture-in-Picture)$"
        "float,class:^(librewolf)$,title:^(Library)$"
        
        # ────────────────────────────────────────────────────────────────────────
        # Floating Windows - Terminal Apps
        # ────────────────────────────────────────────────────────────────────────
        "float,class:^(Alacritty)$,title:^(btop)$"
        "float,class:^(Alacritty)$,title:^(fastfetch)$"
        
        # ────────────────────────────────────────────────────────────────────────
        # Floating Windows - System Tools (Fixed Sizes)
        # ────────────────────────────────────────────────────────────────────────
        "float,class:^(qt5ct)$"
        "float,class:^(qt6ct)$"
        "float,class:^(kvantummanager)$"
        
        "float,class:^(org.pulseaudio.pavucontrol)$"
        "size 1000 700,class:^(org.pulseaudio.pavucontrol)$"
        "center,class:^(org.pulseaudio.pavucontrol)$"
        
        "float,class:^(blueman-manager)$"
        "size 900 650,class:^(blueman-manager)$"
        "center,class:^(blueman-manager)$"
        
        "float,class:^(nm-connection-editor)$"
        "size 900 650,class:^(nm-connection-editor)$"
        "center,class:^(nm-connection-editor)$"
        
        "float,class:^(org.kde.polkit-kde-authentication-agent-1)$"
        
        # ────────────────────────────────────────────────────────────────────────
        # File Dialogs (Fixed Sizes - optimized for side monitors)
        # ────────────────────────────────────────────────────────────────────────
        "float,title:^(Open)$"
        "size 1200 800,title:^(Open)$"
        "center,title:^(Open)$"
        
        "float,title:^(Choose Files)$"
        "size 1200 800,title:^(Choose Files)$"
        "center,title:^(Choose Files)$"
        
        "float,title:^(Save As)$"
        "size 1200 800,title:^(Save As)$"
        "center,title:^(Save As)$"
        
        "float,title:^(Confirm to replace files)$"
        "size 600 400,title:^(Confirm to replace files)$"
        "center,title:^(Confirm to replace files)$"
        
        "float,title:^(File Operation Progress)$"
        "size 600 400,title:^(File Operation Progress)$"
        "center,title:^(File Operation Progress)$"
      ];

      # ════════════════════════════════════════════════════════════════════════
      # LAYER RULES
      # ════════════════════════════════════════════════════════════════════════
      layerrule = [
        "blur,rofi"
        "ignorezero,rofi"
        "blur,notifications"
        "ignorezero,notifications"
      ];

      # ════════════════════════════════════════════════════════════════════════
      # AUTOSTART APPLICATIONS
      # ════════════════════════════════════════════════════════════════════════
      exec-once = [
        # ────────────────────────────────────────────────────────────────────────
        # Scratchpad Terminal (Yakuake-style)
        # ────────────────────────────────────────────────────────────────────────
        "[workspace special:magic silent] alacritty --class scratchpad"
        
        # ────────────────────────────────────────────────────────────────────────
        # Main Monitor (C49RG9x) - Workspaces 1-5
        # ────────────────────────────────────────────────────────────────────────
        "[workspace 1 silent] librewolf"
        "[workspace 2 silent] trilium"
        "[workspace 3 silent] vesktop"
        "[workspace 4 silent] "
        "[workspace 5 silent] "
        
        # ────────────────────────────────────────────────────────────────────────
        # Secondary Monitor (LS32DG30X) - Workspaces 6-10
        # ────────────────────────────────────────────────────────────────────────
        "[workspace 6 silent] spotify"
        "[workspace 7 silent] "
        "[workspace 8 silent] podman-desktop & sleep 2 && podman-desktop"  # Workaround: Doppelstart wegen Bug
        
        # ────────────────────────────────────────────────────────────────────────
        # Vertical Monitor (VE228) - Workspaces 11-15
        # ────────────────────────────────────────────────────────────────────────
        "[workspace 11 silent] eu.betterbird.Betterbird"
        "[workspace 12 silent] nextcloud-talk-desktop"
        "[workspace 13 silent] vorta"
        "[workspace 14 silent] localsend_app"
        "[workspace 14 silent] distrobox enter python_box"
        "[workspace 15 silent] sleep 10;nextcloud"
        "[workspace 15 silent] alacritty -e protonmail-bridge --cli"
        
        # ────────────────────────────────────────────────────────────────────────
        # System Services
        # ────────────────────────────────────────────────────────────────────────
        "wl-paste --watch cliphist store"
      ];
    };
  };
}