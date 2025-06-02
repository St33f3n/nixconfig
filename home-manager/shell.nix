{ pkgs, lib, inputs, ... }:
let starship_config = import ./starship.nix;
in {
  programs.alacritty = {
    enable = true;
    settings = lib.mkForce {
      terminal.shell = { program = "nu"; };
      window.padding = {
        x = 15;
        y = 15;
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
      general = { import = [ "./ocean-koral.toml" ]; };

    };

  };

  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;

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
    };

    extraConfig = ''
      let carapace_completer = {|spans|
      carapace $spans.0 nushell $spans | from json
       }

      $env.config = {
          show_banner: false,
          ls: {
            use_ls_colors: true,
            clickable_links: true,
          }
          table: {
            mode: rounded,
            index_mode: auto,
            padding: {left: 2, right: 2}
          }
          display_errors: {
          termination_signal: false,
          }
          completions: {
            case_sensitive: false,
            quick: true,
            partial: true,
            algorithm: "fuzzy",
            external: {
              enable: true,
              max_results: 30,
              completer: $carapace_completer,
            }
          }
         
        }
         fastfetch
          
    '';
  };
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = lib.mkForce starship_config.starship_string;
  };

  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableNushellIntegration = false;
    icons = "auto";
    colors = "auto";
    git = true;

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
        show_hiden = true;
        sort_by = "natural";
        sort_dir-first = true;
        linemode = "permissions";
        show_symlink = false;
      };
      preview = {
        wrap = "no";
        image_filter = "catmull-rom";
        image_quality = 85;
      };
    };
  };

  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = true;
      };
      updates = { auto_update = true; };
    };

  };

}
