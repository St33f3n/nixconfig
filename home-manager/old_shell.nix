{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Terminal Emulator
  programs.alacritty = {
    enable = true;
    settings = lib.mkForce {
      terminal.shell = {
        program = "${pkgs.nushell}/bin/nu";  # Expliziter Pfad
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

  # Carapace für universelle Completions
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  # Moderne Nushell Konfiguration
  programs.nushell = {
    enable = true;
    
    # Environment Variablen
    environmentVariables = {
      EDITOR = "hx";
      NU_LIB_DIRS = lib.hm.nushell.mkNushellInline ''
        ($nu.default-config-dir | path join 'scripts')
      '';
      CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
    };
    
    # Shell Aliases
    shellAliases = {
      # System Utils
      c = "clear";
      ff = "fastfetch";
      wifi = "nmtui";
      disks = "sudo lsblk -fs";
      mntctrl = "sudo hx /etc/fstab";
      
      # Modern tool replacements (eza)
      ls = "eza --icons --git --group-directories-first";
      ll = "eza --icons --git --group-directories-first -l";
      la = "eza --icons --git --group-directories-first -la";
      tree = "eza --icons --git --tree";
      
      # Yazi shortcut (zusätzlich zum shell wrapper)
      lf = "yazi";
    };
    
    # Moderne Settings Struktur
    settings = {
      # Banner & Editor
      show_banner = false;
      buffer_editor = "hx";
      
      # History (kompatibel mit Atuin)
      history = {
        max_size = 100000;
        file_format = "sqlite";
        isolation = true;
        sync_on_enter = true;
      };
      
      # LS/Table Darstellung
      ls = {
        use_ls_colors = true;
        clickable_links = true;
      };
      
      table = {
        mode = "rounded";
        index_mode = "auto";
        padding = { left = 2; right = 2; };
        header_on_separator = false;
        trim = {
          methodology = "wrapping";
          wrapping_try_keep_words = true;
        };
      };
      
      # Error Display
      display_errors = {
        exit_code = false;
        termination_signal = false;
      };
      
      # File Operations
      rm = {
        always_trash = false;
      };
      
      # Datetime Format (deutsches Format)
      datetime_format = {
        normal = "%d.%m.%Y %H:%M";
        table = "%d.%m.%y %H:%M";
      };
      
      # Completions mit Carapace
      completions = {
        case_sensitive = false;
        quick = true;
        partial = true;
        algorithm = "fuzzy";
        use_ls_colors = true;
        
        external = {
          enable = true;
          max_results = 100;
          completer = lib.hm.nushell.mkNushellInline ''
            {|spans|
              # Alias-Expansion
              let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0.expansion)
              let spans = if $expanded_alias != null {
                $spans | skip 1 | prepend ($expanded_alias | split row ' ' | take 1)
              } else {
                $spans
              }
              
              # Carapace completion
              carapace $spans.0 nushell ...$spans
              | from json
              | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { 
                $in 
              } else { 
                null 
              }
            }
          '';
        };
      };
      
      # Hooks
      hooks = {
        pre_prompt = lib.hm.nushell.mkNushellInline ''
          {||
            # Direnv integration
            if (which direnv | is-not-empty) {
              direnv export json | from json | default {} | load-env
            }
          }
        '';
        
        env_change = {
          PWD = lib.hm.nushell.mkNushellInline ''
            [{|before, after|
              # Zoxide hook
              if (which zoxide | is-not-empty) {
                zoxide add -- $after
              }
            }]
          '';
        };
      };
      
      # Keybindings für bessere Navigation
      keybindings = [
        {
          name = "completion_menu";
          modifier = "none";
          keycode = "tab";
          mode = ["emacs" "vi_normal" "vi_insert"];
          event = {
            until = [
              { send = "menu"; name = "completion_menu"; }
              { send = "menunext"; }
              { edit = "complete"; }
            ];
          };
        }
        {
          name = "completion_previous";
          modifier = "shift";
          keycode = "backtab";
          mode = ["emacs" "vi_normal" "vi_insert"];
          event = { send = "menuprevious"; };
        }
        # Atuin integration (Ctrl+R für History)
        {
          name = "atuin_history";
          modifier = "control";
          keycode = "char_r";
          mode = ["emacs" "vi_normal" "vi_insert"];
          event = { send = "executehostcommand"; cmd = "atuin search -i"; };
        }
      ];
      
      # Menu Konfiguration
      menus = [
        {
          name = "completion_menu";
          only_buffer_difference = false;
          marker = "| ";
          type = {
            layout = "columnar";
            columns = 4;
            col_width = 20;
            col_padding = 2;
          };
          style = {
            text = "green";
            selected_text = "green_reverse";
            description_text = "yellow";
          };
        }
      ];
    };
    
    # Extra Environment
    extraEnv = ''
      # Starship Setup (automatisch durch enableNushellIntegration)
      # Die Integration wird bereits durch programs.starship.enableNushellIntegration gehandhabt
      
      # Path Setup
      $env.PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.local/bin")
      
      # Pager Setup
      $env.PAGER = "less -R"
      
      # Man Pages mit Farben (wenn bat installiert)
      if (which bat | is-not-empty) {
        $env.MANPAGER = "sh -c 'col -bx | bat -l man -p'"
      }
    '';
    
    # Extra Config
    extraConfig = ''
      # Custom Functions
      def mkcd [dir: string] {
        mkdir $dir
        cd $dir
      }
      
      # Pueue shortcuts
      def ps [] { pueue status }
      def pa [...args] { pueue add ...$args }
      def pr [] { pueue restart }
      def pc [] { pueue clean }
      
      # Git shortcuts als Funktionen
      def gst [] { git status }
      def gco [branch: string] { git checkout $branch }
      def gcm [message: string] { git commit -m $message }
      def gp [] { git push }
      def gpl [] { git pull }
      
      # FZF Integration
      if (which fzf | is-not-empty) {
        # Fuzzy file finder mit Preview
        def fzp [] {
          let file = (
            fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' 
                --preview-window=right:60%:wrap
          )
          if ($file | is-not-empty) {
            hx $file
          }
        }
        
        # Fuzzy directory navigation
        def fcd [] {
          let dir = (
            fd --type d --hidden --exclude .git 
            | fzf --preview 'eza --icons --git --color=always --tree --level=2 {}'
          )
          if ($dir | is-not-empty) {
            cd $dir
          }
        }
      }
      
      # Zeige Fastfetch beim Start (nur in interaktiven Sessions)
      if $nu.is-interactive and $env.TERM? != "dumb" {
        fastfetch
      }
    '';
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = lib.mkForce (lib.importTOML ./starship.toml);
  };

  # Atuin für History
  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "host";
      search_mode = "fuzzy";
      search_mode_shell_up_key_binding = "prefix";
      style = "compact";
      inline_height = 20;
      show_preview = true;
      max_preview_height = 4;
      keymap_mode = "auto";
      enter_accept = true;
      
      # UI-Einstellungen
      show_help = true;
      show_tabs = true;
      
      # Stats-Optimierungen  
      common_prefix = [ "sudo" "bundle exec" "docker" "docker-compose" "git" ];
      common_subcommands = [
        "cargo" "git" "npm" "yarn" "docker" "kubectl" "systemctl"
        "sudo" "nix" "nixos-rebuild" "home-manager"
      ];
    };
  };

  # Eza (moderner ls)
  programs.eza = {
    enable = true;
    enableNushellIntegration = true;
    icons = "auto";
    colors = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  # Zoxide (besseres cd)
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  # Yazi File Manager
  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    shellWrapperName = "y";
    settings = {
      manager = {  # Korrigiert von 'mgr'
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
        show_symlink = true;
        scrolloff = 5;
      };

      preview = {
        wrap = "no";
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        image_filter = "lanczos3";
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
  };

  # Tealdeer (tldr pages)
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

  # Direnv - Environment Switcher
  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    
    # Nix-direnv für bessere Nix-Shell Performance
    nix-direnv.enable = true;
    
    # Optional: Stille Modus (weniger Output)
    # silent = true;
    
    # Optional: Custom Config
    config = {
      # Whitelist für spezifische Directories
      whitelist.prefix = [
        "$HOME/projects"
        "$HOME/dev"
      ];
      
      # Performance Einstellungen
      global = {
        warn_timeout = "30s";
        hide_env_diff = false;
      };
    };
    
    # Custom stdlib Erweiterungen
    stdlib = ''
      # Layout für Rust/Cargo Projekte
      layout_rust() {
        if [[ ! -f Cargo.toml ]]; then
          log_error "No Cargo.toml found"
          exit 1
        fi
        
        # Cargo bin directory
        PATH_add "$HOME/.cargo/bin"
        PATH_add "target/debug"
        PATH_add "target/release"
        
        # Rust environment
        export RUST_BACKTRACE="''${RUST_BACKTRACE:-1}"
        export RUST_LOG="''${RUST_LOG:-debug}"
        
        # Sccache für schnellere Builds wenn verfügbar
        if has sccache; then
          export RUSTC_WRAPPER="sccache"
        fi
        
        # Cargo watch aliases
        watch_cargo() {
          cargo watch -x "$@"
        }
      }
      
      # Layout für Python mit uv (modern & schnell)
      layout_uv() {
        if [[ ! -f pyproject.toml ]] && [[ ! -f requirements.txt ]]; then
          log_error "No pyproject.toml or requirements.txt found"
          exit 1
        fi
        
        # UV venv location
        local VENV=".venv"
        
        # Create venv if not exists
        if [[ ! -d "$VENV" ]]; then
          log_status "Creating virtual environment with uv..."
          uv venv "$VENV"
        fi
        
        # Activate venv
        export VIRTUAL_ENV="$(pwd)/$VENV"
        export UV_ACTIVE=1
        PATH_add "$VIRTUAL_ENV/bin"
        
        # Python development settings
        export PYTHONPATH="$(pwd):''${PYTHONPATH}"
        export PYTHONDONTWRITEBYTECODE=1
        export PYTHONUNBUFFERED=1
        
        # Auto-sync dependencies wenn lock file existiert
        if [[ -f "uv.lock" ]]; then
          log_status "Syncing dependencies with uv..."
          uv sync
        fi
      }
      
      # Layout für C++ Projekte
      layout_cpp() {
        # CMake Projekt
        if [[ -f CMakeLists.txt ]]; then
          export CMAKE_EXPORT_COMPILE_COMMANDS=1
          export CMAKE_BUILD_TYPE="''${CMAKE_BUILD_TYPE:-Debug}"
          
          # Build directory setup
          local BUILD_DIR="''${BUILD_DIR:-build}"
          mkdir -p "$BUILD_DIR"
          
          PATH_add "$BUILD_DIR"
          PATH_add "$BUILD_DIR/bin"
          
          # Compiler settings
          export CC="''${CC:-clang}"
          export CXX="''${CXX:-clang++}"
          
          # Ccache für schnellere Builds
          if has ccache; then
            export CMAKE_C_COMPILER_LAUNCHER=ccache
            export CMAKE_CXX_COMPILER_LAUNCHER=ccache
          fi
          
          # Helper function für builds
          cmake_build() {
            cmake -B "$BUILD_DIR" -S . \
              -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
              -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$@"
            cmake --build "$BUILD_DIR" --parallel
          }
          
        # Makefile Projekt
        elif [[ -f Makefile ]] || [[ -f makefile ]]; then
          PATH_add "."
          PATH_add "bin"
          
          export CC="''${CC:-clang}"
          export CXX="''${CXX:-clang++}"
          export CFLAGS="''${CFLAGS:--Wall -Wextra -g}"
          export CXXFLAGS="''${CXXFLAGS:--Wall -Wextra -std=c++20 -g}"
          
          # Parallel builds
          export MAKEFLAGS="''${MAKEFLAGS:--j$(nproc)}"
        fi
        
        # Clangd support (LSP)
        if [[ -f compile_commands.json ]] || [[ -f build/compile_commands.json ]]; then
          if [[ -f build/compile_commands.json ]] && [[ ! -f compile_commands.json ]]; then
            ln -sf build/compile_commands.json compile_commands.json
          fi
        fi
      }
      
      # Layout für Meson Projekte (C/C++/Rust)
      layout_meson() {
        if [[ ! -f meson.build ]]; then
          log_error "No meson.build found"
          exit 1
        fi
        
        local BUILD_DIR="''${BUILD_DIR:-builddir}"
        
        if [[ ! -d "$BUILD_DIR" ]]; then
          log_status "Setting up Meson build..."
          meson setup "$BUILD_DIR"
        fi
        
        PATH_add "$BUILD_DIR"
        export MESON_BUILD_DIR="$BUILD_DIR"
      }
      
      # Universal layout detector
      use_auto() {
        if [[ -f Cargo.toml ]]; then
          log_status "Detected Rust project"
          layout_rust
        elif [[ -f pyproject.toml ]] && has uv; then
          log_status "Detected Python project (using uv)"
          layout_uv
        elif [[ -f pyproject.toml ]] && has poetry; then
          log_status "Detected Python project (using poetry)"
          layout_poetry
        elif [[ -f requirements.txt ]] && has uv; then
          log_status "Detected Python project (using uv)"
          layout_uv
        elif [[ -f CMakeLists.txt ]]; then
          log_status "Detected CMake project"
          layout_cpp
        elif [[ -f Makefile ]] || [[ -f makefile ]]; then
          log_status "Detected Makefile project"
          layout_cpp
        elif [[ -f meson.build ]]; then
          log_status "Detected Meson project"
          layout_meson
        elif [[ -f pnpm-lock.yaml ]]; then
          log_status "Detected pnpm project"
          layout_pnpm
        elif [[ -f package.json ]]; then
          log_status "Detected Node.js project"
          layout node
        else
          log_error "Could not detect project type"
          exit 1
        fi
      }
      
      # Layout für Poetry Projekte (behalten für Kompatibilität)
      layout_poetry() {
        if [[ ! -f pyproject.toml ]]; then
          log_error "No pyproject.toml found"
          exit 1
        fi
        
        local VENV=$(poetry env info --path 2>/dev/null)
        if [[ -n "$VENV" ]]; then
          export VIRTUAL_ENV="$VENV"
          export POETRY_ACTIVE=1
          PATH_add "$VENV/bin"
        fi
      }
      
      # Layout für Node Projekte mit pnpm
      layout_pnpm() {
        if [[ -f pnpm-lock.yaml ]]; then
          PATH_add node_modules/.bin
          export NODE_ENV="''${NODE_ENV:-development}"
        fi
      }
    '';
  };
  
  # Pueue Task Manager
  services.pueue = {
    enable = true;
    settings = {
      shared = {
        default_parallel_tasks = 10;
      };
    };
  };
}
