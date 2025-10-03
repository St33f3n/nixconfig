{ lib, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    # ============================================================================
    # EDITOR SETTINGS
    # ============================================================================
    settings = {
      theme = lib.mkForce "ocean-coral";

      editor = {
        # ────────────────────────────────────────────────────────────────────────
        # System Integration
        # ────────────────────────────────────────────────────────────────────────
        clipboard-provider = "wayland";

        # ────────────────────────────────────────────────────────────────────────
        # Visual Settings
        # ────────────────────────────────────────────────────────────────────────
        line-number = "relative";
        cursorline = true;
        rulers = [
          120  # Primary ruler for most code
          200  # Secondary ruler for max line length
        ];
        bufferline = "always";
        color-modes = true;
        scroll-lines = 3;
        scrolloff = 5;

        cursor-shape = {
          insert = "bar";
          normal = "block";
        };

        # ────────────────────────────────────────────────────────────────────────
        # Indent Guides
        # ────────────────────────────────────────────────────────────────────────
        indent-guides = {
          render = true;
          character = "│";
          skip-levels = 1;
        };

        # ────────────────────────────────────────────────────────────────────────
        # Editor Behavior
        # ────────────────────────────────────────────────────────────────────────
        auto-save = true;
        idle-timeout = 50;
        auto-completion = true;
        completion-trigger-len = 1;
        auto-format = true;
        auto-pairs = true;

        # ────────────────────────────────────────────────────────────────────────
        # LSP Configuration
        # ────────────────────────────────────────────────────────────────────────
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
          auto-signature-help = true;
          display-signature-help-docs = true;
          snippets = true;
        };

        # ────────────────────────────────────────────────────────────────────────
        # Diagnostics Display
        # ────────────────────────────────────────────────────────────────────────
        end-of-line-diagnostics = "hint";

        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "disable";
        };

        # ────────────────────────────────────────────────────────────────────────
        # Status Line Configuration
        # ────────────────────────────────────────────────────────────────────────
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "version-control"
          ];
          center = [
            "diagnostics"
            "workspace-diagnostics"
          ];
          right = [
            "position"
            "position-percentage"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
          separator = "│";
        };

        # ────────────────────────────────────────────────────────────────────────
        # File Picker Settings
        # ────────────────────────────────────────────────────────────────────────
        file-picker = {
          hidden = true;
          parents = true;
          ignore = true;
          git-ignore = false;
          git-global = true;
          git-exclude = true;
          max-depth = 10;
        };

        # ────────────────────────────────────────────────────────────────────────
        # Gutter Configuration
        # ────────────────────────────────────────────────────────────────────────
        gutters = {
          layout = [
            "diff"
            "diagnostics"
            "line-numbers"
            "spacer"
          ];
        };
      };
    };

    # ============================================================================
    # KEY BINDINGS
    # ============================================================================
    extraConfig = ''
      # ──────────────────────────────────────────────────────────────────────────
      # Normal Mode Keybindings
      # ──────────────────────────────────────────────────────────────────────────
      [keys.normal]
      # ESC behaviour: collapse selection and keep primary
      esc = ["collapse_selection", "keep_primary_selection"]
      
      # Window navigation: Quick switching between splits
      C-h = "jump_view_left"    # Ctrl+h: Move to left window
      C-j = "jump_view_down"    # Ctrl+j: Move to window below
      C-k = "jump_view_up"      # Ctrl+k: Move to window above
      C-l = "jump_view_right"   # Ctrl+l: Move to right window
      
      # Register behavior: Delete without overwriting yank register
      # Helix Selection-First: Erst selektieren (w, miw, x, etc), dann Action
      d = "delete_selection_noyank"  # d: Löscht OHNE zu yanken (Problem gelöst!)
      C-x = ["yank_main_selection_to_clipboard", "delete_selection"]  # Ctrl+x: Explizites Cut
      
      # Buffer/Tab navigation
      H = "goto_previous_buffer"  # Shift+h: Previous buffer
      L = "goto_next_buffer"      # Shift+l: Next buffer

      # ──────────────────────────────────────────────────────────────────────────
      # Insert Mode Keybindings
      # ──────────────────────────────────────────────────────────────────────────
      [keys.insert]
      # Quick escape alternatives
      j.k = "normal_mode"  # Type 'jk' quickly to exit insert mode
      
      # ──────────────────────────────────────────────────────────────────────────
      # Select Mode Keybindings
      # ──────────────────────────────────────────────────────────────────────────
      [keys.select]
      # Same delete behavior in select mode
      d = "delete_selection_noyank"
      C-x = ["yank_main_selection_to_clipboard", "delete_selection"]
    '';

    # ============================================================================
    # LANGUAGE CONFIGURATIONS
    # ============================================================================
    languages = {
      # ──────────────────────────────────────────────────────────────────────────
      # Language Server Definitions
      # ──────────────────────────────────────────────────────────────────────────
      language-server = {
        # Rust Language Server (rust-analyzer)
        rust-analyzer = {
          command = "rust-analyzer";
          config = {
            check.command = "clippy";

            inlayHints = {
              bindingModeHints.enable = false;
              closingBraceHints.minLines = 10;
              closureReturnTypeHints.enable = "with_block";
              discriminantHints.enable = "fieldless";
              lifetimeElisionHints.enable = "skip_trivial";
              typeHints.hideClosureInitialization = false;
            };

            files.watcher = "server";
            cargo.features = "all";
          };
        };

        # Python - Ruff LSP (2024/2025 empfohlen, alles-in-einem)
        ruff = {
          command = "ruff";
          args = [ "server" ];
          config = {
            settings = {
              # Ruff configuration
              lineLength = 88;
              lint = {
                select = [ "E" "F" "I" ];  # Enable specific rule categories
              };
            };
          };
        };

        # C/C++ Language Server (clangd)
        clangd = {
          command = "clangd";
          args = [
            "--function-arg-placeholders"
            "--completion-style=detailed"
            "--clang-tidy"
            "--enable-config"
          ];
          config = {
            fallbackFlags = [ "-std=c++20" ];
          };
        };

        # Nix Language Server (nixd - 2024/2025 empfohlen)
        nixd = {
          command = "nixd";
        };

        # CUE Language Server
        cue-lsp = {
          command = "cue";
          args = [ "lsp" ];
        };

        # Additional Language Servers
        marksman = {
          command = "marksman";
          args = [ "server" ];
        };

        yaml-language-server = {
          command = "yaml-language-server";
          args = [ "--stdio" ];
        };

        taplo = {
          command = "taplo";
          args = [ "lsp" "stdio" ];
        };
      };

      # ──────────────────────────────────────────────────────────────────────────
      # Debugger Configuration
      # ──────────────────────────────────────────────────────────────────────────
      debugger = [
        {
          name = "lldb-dap";
          transport = "stdio";
          command = "lldb-dap";

          templates = [
            {
              name = "binary";
              request = "launch";
              completion = [
                {
                  name = "binary";
                  completion = "filename";
                }
              ];
              args = {
                program = "{0}";
              };
            }
            {
              name = "attach";
              request = "attach";
              completion = [ "pid" ];
              args = {
                pid = "{0}";
              };
            }
          ];
        }
      ];

      # ──────────────────────────────────────────────────────────────────────────
      # Language-Specific Settings
      # ──────────────────────────────────────────────────────────────────────────
      language = [
        # Python - Modern setup with Ruff only
        {
          name = "python";
          auto-format = true;
          language-servers = [ "ruff" ];  # Nur Ruff für Linting + Formatting
          formatter = {
            command = "ruff";
            args = [
              "format"
              "--line-length"
              "88"
              "--stdin-filename"
              "file.py"
              "-"
            ];
          };
          rulers = [ 88 ];
        }

        # Rust
        {
          name = "rust";
          auto-format = true;
          language-servers = [ "rust-analyzer" ];
        }

        # C++
        {
          name = "cpp";
          auto-format = true;
          language-servers = [ "clangd" ];
          formatter = {
            command = "clang-format";
            args = [ "--style=file" ];
          };
        }

        # C
        {
          name = "c";
          auto-format = true;
          language-servers = [ "clangd" ];
          formatter = {
            command = "clang-format";
            args = [ "--style=file" ];
          };
          indent = {
            tab-width = 4;
            unit = "  ";
          };
        }

        # Nix
        {
          name = "nix";
          auto-format = true;
          language-servers = [ "nixd" ];
          formatter = {
            command = "nixfmt";
          };
        }

        # CUE Configuration Language
        {
          name = "cue";
          auto-format = true;
          language-servers = [ "cue-lsp" ];
          formatter = {
            command = "cue";
            args = [ "fmt" "-" ];
          };
        }

        # Nu Shell
        {
          name = "nu";
          auto-format = true; 
          comment-token = "#";
          file-types = [ "nu" ];
          roots = [ ];
          scope = "source.nu";
          shebangs = [ "nu" ];
        }

        # Markdown
        {
          name = "markdown";
          auto-format = true;
          language-servers = [ "marksman" ];
        }

        # YAML
        {
          name = "yaml";
          auto-format = true;
          language-servers = [ "yaml-language-server" ];
        }

        # TOML
        {
          name = "toml";
          auto-format = true;
          language-servers = [ "taplo" ];
        }
      ];
    };

    # ============================================================================
    # THEME CONFIGURATION
    # ============================================================================
    themes = {
      ocean-coral = builtins.fromTOML (builtins.readFile ./helix-themes/ocean-coral.toml);
    };
  };
}