{ lib, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    # Editor settings aus config.toml
    settings = {
      theme = lib.mkForce "ocean-coral";

      editor = {
        clipboard-provider = "wayland";
        line-number = "relative";
        cursorline = true;
        rulers = [
          120
          200
        ];
        auto-save = true;
        idle-timeout = 50;
        completion-trigger-len = 1;
        bufferline = "always";
        color-modes = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
        };

        auto-completion = true;
        auto-format = true;
        auto-pairs = true;
        scroll-lines = 3;
        scrolloff = 5;

        end-of-line-diagnostics = "hint";

        indent-guides = {
          render = true;
          character = "│";
          skip-levels = 1;
        };

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
          auto-signature-help = true;
          display-signature-help-docs = true;
          snippets = true;
        };

        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "disable";
        };

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

        file-picker = {
          hidden = true;
          parents = true;
          ignore = true;
          git-ignore = true;
          git-global = true;
          git-exclude = true;
          max-depth = 10;
        };

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

    # Key bindings
    extraConfig = ''
      [keys.normal]
      esc = ["collapse_selection", "keep_primary_selection"]
    '';

    # Language configuration - korrigierte Syntax
    languages = {
      # Language server definitions
      language-server = {
        # Rust language server
        rust-analyzer = {
          command = "rust-analyzer";
          config = {
            # Enable clippy linting
            check.command = "clippy";

            # Inlay hints configuration
            inlayHints = {
              bindingModeHints.enable = false;
              closingBraceHints.minLines = 10;
              closureReturnTypeHints.enable = "with_block";
              discriminantHints.enable = "fieldless";
              lifetimeElisionHints.enable = "skip_trivial";
              typeHints.hideClosureInitialization = false;
            };

            # File watcher configuration
            files.watcher = "server";

            # Cargo features
            cargo.features = "all";
          };
        };

        # Python - using pyright (Microsoft's LSP, recommended 2024/2025)
        pyright = {
          command = "pyright-langserver";
          args = [ "--stdio" ];
          config = {
            python.analysis = {
              typeCheckingMode = "basic";
              autoSearchPaths = true;
              useLibraryCodeForTypes = true;
            };
          };
        };

        # Ruff LSP for fast Python linting and formatting
        ruff = {
          command = "ruff";
          args = [ "server" ];
        };

        # C++ language server
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

        # Nix language server - using nixd (2024/2025 recommended)
        nixd = {
          command = "nixd";
        };

        # Alternative Nix LSP (stable option)
        nil = {
          command = "nil";
        };
      };

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

      # Language configurations
      language = [
        # Python configuration with modern tooling
        {
          name = "python";
          auto-format = true;
          language-servers = [
            "pyright"
            "ruff"
          ];
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

        {
          name = "rust";
          auto-format = true;
          language-servers = [ "rust-analyzer" ];
        }

        # C++ - same debugger reference
        {
          name = "cpp";
          auto-format = true;
          language-servers = [ "clangd" ];
          formatter = {
            command = "clang-format";
            args = [ "--style=file" ];
          };
        }

        # C configuration (same as C++)
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

        # Nix configuration
        {
          name = "nix";
          auto-format = true;
          language-servers = [ "nil" ]; # Change to "nil" if preferred
          formatter = {
            command = "nixfmt"; # Use "alejandra" as alternative
          };
        }

        # Nu shell configuration (limited LSP support)
        {
          name = "nu";
          auto-format = false; # No stable formatter yet
          comment-token = "#";
          file-types = [ "nu" ];
          roots = [ ];
          scope = "source.nu";
          shebangs = [ "nu" ];
        }

        # Additional language configurations
        {
          name = "markdown";
          auto-format = true;
          language-servers = [ "marksman" ];
        }

        {
          name = "yaml";
          auto-format = true;
          language-servers = [ "yaml-language-server" ];
        }

        {
          name = "toml";
          auto-format = true;
          language-servers = [ "taplo" ];
        }
      ];
    };
    themes = {
      ocean-coral = builtins.fromTOML (builtins.readFile ./helix-themes/ocean-coral.toml);
    };
  };
}
