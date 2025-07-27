{ lib, ... }:
{
  programs.helix = {
    enable = true;
    
    # Editor settings aus config.toml
    settings = {
      theme =  lib.mkForce "ocean-coral";
      
      editor = {
        clipboard-provider = "termcode";
        line-number = "relative";
        cursorline = true;
        rulers = [120 200];
        auto-save = true;
        idle-timeout = 50;
        completion-trigger-len = 1;
        bufferline = "always";
        color-modes = true;
        
        cursor-shape = {
          insert = "bar";
          normal = "block";
        };
        
        indent-guides = {
          render = true;
          character = "│";
          skip-levels = 1;
        };
        
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        
        statusline = {
          left = ["mode" "spinner" "file-name" "version-control"];
          center = ["diagnostics" "workspace-diagnostics"];
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
      };
    };
    
    # Key bindings
    extraConfig = ''
      [keys.normal]
      esc = ["collapse_selection", "keep_primary_selection"]
    '';
    
    # Language configuration - korrigierte Syntax
    languages = {
      # Language servers definieren
      language-server = {
        pylsp = {
          command = "pylsp";
          config.pylsp.plugins = {
            ruff = { enabled = true; };
            pycodestyle = { enabled = false; };
            pyflakes = { enabled = false; };
            mccabe = { enabled = false; };
          };
        };
        rust-analyzer = {
          command = "rust-analyzer";
        };
        taplo = {
          command = "taplo";
          args = ["lsp" "stdio"];
        };
        yaml-language-server = {
          command = "yaml-language-server";
          args = ["--stdio"];
        };
        clangd = {
          command = "clangd";
        };
      };
      
      # Sprachen mit Verweis auf Language servers
      language = [
        {
          name = "rust";
          scope = "source.rust";
          injection-regex = "rust";
          file-types = ["rs"];
          indent = { tab-width = 4; unit = "    "; };
          language-servers = ["rust-analyzer"];  # ← Plural und Array
          auto-format = true;
        }
        {
          name = "python";
          scope = "source.python";
          injection-regex = "python";
          file-types = ["py"];
          shebangs = ["python"];
          roots = ["pyproject.toml" "setup.py" "poetry.lock" "requirements.txt"];
          indent = { tab-width = 4; unit = "    "; };
          formatter = { command = "black"; args = ["--quiet" "-"]; };
          language-servers = ["pylsp"];  # ← Korrekte Syntax
          auto-format = true;
        }
        {
          name = "toml";
          scope = "source.toml";
          injection-regex = "toml";
          file-types = ["toml"];
          comment-token = "#";
          language-servers = ["taplo"];
          indent = { tab-width = 2; unit = "  "; };
        }
        {
          name = "yaml";
          scope = "source.yaml";
          injection-regex = "yaml";
          file-types = ["yaml" "yml"];
          roots = [];
          comment-token = "#";
          language-servers = ["yaml-language-server"];
          indent = { tab-width = 2; unit = "  "; };
        }
        {
          name = "cpp";
          scope = "source.cpp";
          injection-regex = "cpp";
          file-types = ["cpp" "hpp" "cc" "hh" "cxx" "hxx"];
          roots = ["compile_commands.json" ".clangd"];
          language-servers = ["clangd"];
          indent = { tab-width = 4; unit = "    "; };
        }
      ];
    };
    
    # Custom themes
    themes = {
      ocean-coral = builtins.fromTOML (builtins.readFile ./helix-themes/ocean-coral.toml);
    };
  };
}
