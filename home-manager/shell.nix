{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.alacritty = {
    enable = true;
    settings = lib.mkForce {
      terminal.shell = {
        program = "nu";
      };
      window = {
        padding = {
          x = 15;
          y = 15;
        };
        opacity = 0.95;
      };
      keyboard.bindings = [
        {
          key = "v";
          mods = "Control|Super";
          mode = "AppCursor|AppKeypad|Alt|Search|Vi";
          action = "paste";
        }
        {
          key = "c";
          mods = "Control|Super";
          mode = "AppCursor|AppKeypad|Alt|Search|Vi";
          action = "copy";
        }
        {
          key = "Back";
          mods = "Control";
          chars = "\\u0017";
        }
      ];
      general = {
        import = [ "./ocean-koral.toml" ];
      };
    };
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.nushell = {
    enable = true;

    environmentVariables = {
      EDITOR = "hx";
      NU_LIB_DIRS = "./scripts";
    };

    shellAliases = {
      c = "clear";
      ff = "fastfetch";
      wifi = "nmtui";
      disks = "sudo lsblk -fs";
      mntctrl = "sudo hx /etc/fstab";
      
      # Modern tool replacements
      ls = "eza --icons --git --group-directories-first";
      ll = "eza --icons --git --group-directories-first -l";
      la = "eza --icons --git --group-directories-first -la";
      tree = "eza --icons --git --tree";
    };

    # Moderne modulare Konfiguration statt monolithischen $env.config
    extraConfig = ''
      # Carapace completion setup
      let carapace_completer = {|spans|
        carapace $spans.0 nushell $spans | from json
      }

      # Moderne Nushell-Konfiguration (modulär)
      $env.config.show_banner = false
      $env.config.buffer_editor = "hx"
      
      # History-Optimierungen (funktioniert mit Atuin)
      $env.config.history.max_size = 100_000
      $env.config.history.file_format = "sqlite"
      $env.config.history.isolation = true
      
      # Performance-Optimierungen
      $env.config.ls.use_ls_colors = true
      $env.config.ls.clickable_links = true
      
      # Table-Darstellung
      $env.config.table.mode = "rounded"
      $env.config.table.index_mode = "auto"
      $env.config.table.padding = {left: 2, right: 2}
      
      # Error-Display
      $env.config.display_errors.termination_signal = false
      
      # Completion-Setup (integriert mit Carapace UND Atuin)
      $env.config.completions.case_sensitive = false
      $env.config.completions.quick = true
      $env.config.completions.partial = true
      $env.config.completions.algorithm = "fuzzy"
      $env.config.completions.external.enable = true
      $env.config.completions.external.max_results = 30
      $env.config.completions.external.completer = $carapace_completer
      
      # Eza-Integration in Nushell (da enableNushellIntegration = false)
      def la [] { eza --icons --git --group-directories-first -la }
      def ll [] { eza --icons --git --group-directories-first -l }
      def lt [] { eza --icons --git --tree --level=3 }
      
      fastfetch
    '';
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = lib.mkForce (lib.importTOML ./starship.toml);
  };

  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      # Flexiblere Atuin-Konfiguration
      filter_mode = "global";                           # Standard: alles anzeigen
      filter_mode_shell_up_key_binding = "host";        # Up-Arrow: nur dieser Host
      search_mode = "fuzzy";                             # Bessere Suche
      search_mode_shell_up_key_binding = "prefix";      # Up-Arrow: prefix search
      style = "compact";                                 # Weniger UI-Clutter
      inline_height = 20;                               # Mehr Platz für Ergebnisse
      show_preview = true;                               # Command-Preview
      max_preview_height = 4;                           # Preview-Größe
      keymap_mode = "auto";                             # Auto-detect vim/emacs
      enter_accept = true;                              # Enter führt direkt aus
    };
  };

  programs.eza = {
    enable = true;
    enableNushellIntegration = false;  # Manuell in extraConfig integriert
    icons = "auto";
    colors = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    shellWrapperName = "y";
    settings = {
      manager = {
        show_hidden = true;                # Typo-Fix
        sort_by = "natural";
        sort_dir_first = true;             # Syntax-Fix
        linemode = "size";                 # Zeigt size + permissions
        show_symlink = true;               # Symlink-Ziele anzeigen
        scrolloff = 5;                     # Cursor-Padding
      };
      preview = {
        wrap = "no";
        tab_size = 2;                      # Kleinere Tabs
        max_width = 600;                   # Größere Preview
        max_height = 900;
        image_filter = "lanczos3";         # Beste Bildqualität
        image_quality = 90;
      };
      opener = {
        edit = [
          { run = "hx \"$@\""; block = true; desc = "helix"; }
        ];
        play = [
          { run = "mpv \"$@\""; orphan = true; desc = "mpv"; }
        ];
      };
    };
    
    # Git-Plugin Integration
    initLua = ''
      require("git"):setup()
      require("full-border"):setup()
    '';
  };

  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = true;
      };
      updates = {
        auto_update = true;
      };
    };
  };

  # Zusätzliche Atuin-Konfiguration
  home.file.".config/atuin/config.toml".text = ''
    # Erweiterte Atuin-Einstellungen für bessere UX
    [search]
    # Ctrl-R: Global fuzzy search
    # Up-Arrow: Host-specific prefix search (aus programs.atuin.settings)
    
    [ui]
    show_help = true
    show_tabs = true
    
    [stats]
    common_prefix = ["sudo", "bundle exec", "docker", "docker-compose", "git"]
    common_subcommands = [
      "cargo", "git", "npm", "yarn", "docker", "kubectl", "systemctl",
      "sudo", "nix", "nixos-rebuild", "home-manager"
    ]
  '';
}
