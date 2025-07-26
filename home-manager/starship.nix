{
  starship_string = {
    add_newline = false;
    command_timeout = 2000;
    
    # Optimiertes Format: Gradient von links nach rechts mit besserer Lesbarkeit
    format = "[░▒▓](fg:deep_sapphire bg:abyss)$os$username$hostname[](fg:deep_sapphire bg:kelp_green)$directory$git_branch$git_status[](fg:kelp_green bg:deep_teal)$dev_env[](fg:deep_teal bg:coral_accent)$time$memory_usage[](fg:coral_accent)$character\n[└─>](fg:sea_foam) ";

    # Ocean-Koral Farbpalette - optimiert für besseren Kontrast
    palette = "ocean_koral";
    palettes.ocean_koral = {
      # Basis-Farben aus deinem Alacritty-Theme
      abyss = "#1e1e1e";              # Dein background
      deep_sapphire = "#262626";       # Dein footer_bar bg
      kelp_green = "#4a6b4a";         # Gedämpftes Grün
      deep_teal = "#5a9a9a";          # Dein cyan
      coral_accent = "#c84a2c";        # Dein red (coral-red)
      sea_foam = "#6b8e6b";           # Dein green
      text_primary = "#f7f2e3";       # Dein foreground
      text_muted = "#c4b89f";         # Dein dim_foreground
      
      # Feature-Farben für Programmiersprachen
      rust_orange = "#d49284";         # Für Rust
      python_blue = "#6b8db3";         # Für Python  
      ts_blue = "#7ba3d4";            # Für TypeScript
      docker_cyan = "#5a9a9a";        # Für Docker
      go_cyan = "#4a7a7a";            # Für Go
      julia_purple = "#b85347";       # Für Julia
      zig_yellow = "#d4634a";         # Für Zig
    };

    # OS-Symbol mit besserer Distro-Unterstützung
    os = {
      format = "[$symbol](bold bg:deep_sapphire fg:text_primary)";
      disabled = false;
      symbols = {
        Arch = " ";
        Ubuntu = " ";
        Debian = " ";
        Raspbian = " ";
        CentOS = " ";
        Manjaro = " ";
        NixOS = " ";
        EndeavourOS = " ";
        Linux = " ";
      };
    };

    # User & Hostname - kompakt aber informativ
    username = {
      style_user = "bold bg:deep_sapphire fg:text_primary";
      style_root = "bold bg:coral_accent fg:text_primary";
      format = "[ $user]($style)";
      disabled = false;
      show_always = true;
    };

    hostname = {
      style = "bold bg:deep_sapphire fg:text_muted";
      format = "[@$hostname ]($style)";
      disabled = false;
      ssh_only = false;
    };

    # Directory - bessere Truncation
    directory = {
      style = "bold bg:kelp_green fg:text_primary";
      format = "[ $path ]($style)";
      truncation_length = 3;
      truncate_to_repo = true;
      truncation_symbol = "…/";
      home_symbol = "󰟐 ";
      read_only = " 󰌾";
    };

    # Git - informativ aber kompakt
    git_branch = {
      style = "bold bg:kelp_green fg:text_primary";
      format = "[ $symbol$branch]($style)";
      symbol = " ";
      truncation_length = 20;
    };

    git_status = {
      style = "bold bg:kelp_green fg:coral_accent";
      format = "[$all_status$ahead_behind ]($style)";
      conflicted = "󰞇 ";
      ahead = "⇡${count} ";
      behind = "⇣${count} ";
      diverged = "⇕⇡${ahead_count}⇣${behind_count} ";
      up_to_date = "";
      untracked = "? ";
      stashed = "󰜦 ";
      modified = " ";
      staged = "+ ";
      renamed = "󰑕 ";
      deleted = " ";
    };

    # Development Environment - alle deine Sprachen mit Feature-Farben
    dev_env = {
      format = "$rust$python$nodejs$julia$golang$zig$c$cmake$docker$ansible$yaml";
    };

    # Rust - mit Feature-Farbe
    rust = {
      style = "bold bg:deep_teal fg:rust_orange";
      format = "[ $symbol$version ]($style)";
      symbol = "🦀 ";
    };

    # Python - mit Feature-Farbe  
    python = {
      style = "bold bg:deep_teal fg:python_blue";
      format = "[ $symbol$version ]($style)";
      symbol = " ";
    };

    # Node.js/TypeScript - mit Feature-Farbe
    nodejs = {
      style = "bold bg:deep_teal fg:ts_blue";
      format = "[ $symbol$version ]($style)";
      symbol = " ";
    };

    # Julia - mit Feature-Farbe
    julia = {
      style = "bold bg:deep_teal fg:julia_purple";
      format = "[ $symbol$version ]($style)";
      symbol = " ";
    };

    # Go - mit Feature-Farbe
    golang = {
      style = "bold bg:deep_teal fg:go_cyan";
      format = "[ $symbol$version ]($style)";
      symbol = "󰟓 ";
    };

    # Zig - mit Feature-Farbe
    zig = {
      style = "bold bg:deep_teal fg:zig_yellow";
      format = "[ $symbol$version ]($style)";
      symbol = " ";
    };

    # C/C++ - kompakt
    c = {
      style = "bold bg:deep_teal fg:text_primary";
      format = "[ $symbol$version ]($style)";
      symbol = " ";
    };

    cmake = {
      style = "bold bg:deep_teal fg:text_primary";
      format = "[ $symbol$version ]($style)";
      symbol = " ";
    };

    # Docker - mit Feature-Farbe
    docker_context = {
      style = "bold bg:deep_teal fg:docker_cyan";
      format = "[ $symbol$context ]($style)";
      symbol = " ";
    };

    # DevOps Tools
    ansible = {
      style = "bold bg:deep_teal fg:coral_accent";
      format = "[ $symbol$version ]($style)";
      symbol = "󱂚 ";
    };

    # YAML für Ansible/K8s
    yaml = {
      style = "bold bg:deep_teal fg:text_muted";
      format = "[ $symbol ]($style)";
      symbol = " ";
    };

    # Time & Memory - rechter Rand
    time = {
      disabled = false;
      time_format = "%H:%M";
      style = "bold bg:coral_accent fg:text_primary";
      format = "[ 󰥔 $time ]($style)";
    };

    # Memory - optimierter Threshold für bessere Performance
    memory_usage = {
      disabled = false;
      threshold = 75;  # Nur anzeigen wenn >75% verwendet
      style = "bold bg:coral_accent fg:text_primary";
      format = "[ 󰍛 $\{ram_pct\} ]($style)";
    };

    # Character - status-sensitiv
    character = {
      success_symbol = "[ ](bold fg:sea_foam)";
      error_symbol = "[ ](bold fg:coral_accent)";
      vimcmd_symbol = "[ ](bold fg:julia_purple)";
    };

    # Nix Shell - wichtig für NixOS-User
    nix_shell = {
      style = "bold bg:deep_teal fg:text_primary";
      format = "[ $symbol$name ]($style)";
      symbol = "󱄅 ";
    };

    # Package Manager Context
    package = {
      style = "bold bg:deep_teal fg:text_muted";
      format = "[ $symbol$version ]($style)";
      symbol = "󰏗 ";
    };
  };
}
