{
  starship_string = {

    add_newline = false;
    command_timeout = 1000;
    format = "[░▒▓](fg:deep_sapphire bg:midnight)$os[󰛡 ](fg:beige bg:deep_sapphire)$username$hostname[󰛡 ](fg:deep_sapphire bg:kelp_green)$directory$git_status$git_branch[󰛡 ](fg:kelp_green bg:deep_teal)$rust$python$golang$nodejs$java$nix_shell$elixr$julia$kotlin$c$ruby$cmake$dart$lua$zig$package$docker_context[󰛡](bg:coral_pink fg:deep_teal)$time$memory_usage$character[󰛡 ](fg:coral_pink  )$cmd_duration\n[└─>](fg:sea_foam)";

    palette = "ocean";
    palettes.ocean = {
      primary_accent = "#0088cc"; # coral-blue
      surface = "#263440"; # surface
      deep_water = "#1a2832"; # deep-water
      deep_teal = "#006666"; # deep-teal
      coral_orange = "#ff6347"; # coral-orange
      coral_deep = "#d65d52"; # coral-deep
      deep_sapphire = "#004d66"; # deep-sapphire
      text_primary = "#e6f3f7"; # text-primary
      text_secondary = "#b3d1d9"; # text-secondary
      kelp_green = "#1d4d4f";
      coral_red = "#ff4500";
      sea_foam = "#2d8a8a";
      coral_blue = "#0088cc";
      arctic_blue = "#00bfff";
      bioluminescent = "#00c2c2";
      abyss = "#141e26";
      coral_light = "#ffa07a";
      coral_pink = "#e57f6f";
      seafoam_gray = "#a3b8c2";
      marine_blue = "#006bb3";
      midnight = "#202d36";
      beige = "#ffcc99";
    };

    fill = {
      style = "coral_light";
      symbol = "󰛡";
    };

    os = {
      format = "[$symbol](bg:deep_sapphire fg:arctic_blue)";
      disabled = false;
    };

    username = {
      style_root = "fg:beige bg:deep_sapphire";
      style_user = "fg:beige bg:deep_sapphire";
      format = "[$user]($style)";
      disabled = false;
      show_always = true;
    };
    hostname = {
      style = "bold fg:beige bg:deep_sapphire";
      ssh_only = false;
      format = "[ 󰿨 ](bold $style)[$hostname$ssh_symbol]($style)";
      disabled = false;
      ssh_symbol = " ";
    };

    directory = {
      read_only = " ";
      home_symbol = "󰟐 ";
      truncation_length = 4;
      truncate_to_repo = true;
      truncation_symbol = "󰇘/";
      format = "[$path ]($style)";
      style = "bold fg:coral_light bg:kelp_green";
    };

    git_branch = {
      symbol = "";
      format = "[$symbol$branch ]($style)";
      truncation_symbol = "…/";
      style = "bold fg:coral_light bg:kelp_green";
    };

    git_status = {
      format = "[$all_status$ahead_behind ]($style)";
      style = "bold fg:coral_light bg:kelp_green";
      conflicted = "🏳";
      up_to_date = "";
      untracked = " ";
      ahead = "⇡\${count}";
      diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
      behind = "⇣\${count} ";
      stashed = "󰜦";
      modified = "";
      staged = "[++($count)]($style)";
      renamed = "襁 ";
      deleted = "󱂥";
    };

    git_commit = { tag_symbol = "  "; };

    character = {
      format = "$symbol";
      success_symbol = "[ 󰄴 ](bold bg:coral_pink fg:deep_teal)";
      error_symbol = "[ 󰳶 ](fg:black bg:bright-red)[](fg:bright-red)";
      vimcmd_symbol = "[  ](fg:black bg:bright-red)[](fg:bright-red)";
    };

    docker_context = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    package = {
      symbol = "󰏖 ";
      format = "[ $symbol$version ]($style)";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    memory_usage = {
      symbol = " ";
      style = "bold bg:coral_pink fg:deep_teal";
      format = "[$symbol\${ram_pct}]($style)";
      threshold = 1;
      disabled = false;
    };

    python = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    rust = {
      symbol = "🦀 ";
      format = "[$symbol($version)]($style)";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    golang = {
      symbol = "󰟓 ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    nodejs = {
      symbol = "";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    java = {
      symbol = "󰬷 ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    aws = {
      symbol = "󰸏 ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    c = {
      symbol = "󰙱 ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    ruby = {
      symbol = "rb ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    scala = {
      symbol = "scala ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    bun = {
      symbol = "bun";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    cobol = {
      symbol = "cobol ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    conda = {
      symbol = "󱔎 ";
      ignore_base = true;
      format = "[$symbol$environment on ](bg:blue bold fg:green)";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    crystal = {
      symbol = "cr ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    cmake = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    daml = {
      symbol = "daml ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    dart = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    deno = {
      symbol = "deno ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    dotnet = {
      symbol = "󰪮 ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    elixir = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    elm = {
      symbol = "elm ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    guix_shell = {
      symbol = "guix ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    hg_branch = {
      symbol = "hg ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    julia = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    kotlin = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    lua = {
      symbol = "󰢱 ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    meson = {
      symbol = "meson ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    nim = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    nix_shell = {
      symbol = "󱄅 ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    ocaml = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    opa = {
      symbol = "opa ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    os.symbols = { # Note the dot notation for nested tables
      Alpine = " ";
      Amazon = " ";
      Android = " ";
      Arch = "󰣇 ";
      CentOS = " ";
      Debian = " ";
      DragonFly = "dfbsd ";
      Emscripten = "emsc ";
      EndeavourOS = " ";
      Fedora = " ";
      FreeBSD = "󰣠 ";
      Garuda = "garu ";
      Gentoo = "󰣨 ";
      HardenedBSD = "hbsd ";
      Illumos = "lum ";
      Linux = " ";
      Macos = "mac ";
      Manjaro = "󱘊 ";
      Mariner = "mrn ";
      MidnightBSD = "mid ";
      Mint = "󰣭 ";
      NetBSD = "nbsd ";
      NixOS = "󱄅 ";
      OpenBSD = "obsd ";
      openSUSE = " ";
      OracleLinux = "orac ";
      Pop = "pop ";
      Raspbian = " ";
      Redhat = "rhl ";
      RedHatEnterprise = "rhel ";
      Redox = "redox ";
      Solus = "sol ";
      SUSE = "suse ";
      Ubuntu = " ";
      Unknown = "unk ";
      Windows = " ";
    };

    perl = {
      symbol = "pl ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    php = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    pulumi = {
      symbol = "pulumi ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    purescript = {
      symbol = "purs ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    raku = {
      symbol = "raku ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    spack = {
      symbol = "spack ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    sudo = {
      symbol = "󰆥 ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    swift = {
      symbol = "swift ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    terraform = {
      symbol = "terraform ";
      style = "bold fg:coral_deep bg:deep_teal";
    };
    zig = {
      symbol = " ";
      style = "bold fg:coral_deep bg:deep_teal";
    };

    time = {
      disabled = false;
      time_format = "%H:%M:%S %Y-%m-%d";
      style = "bold bg:coral_pink fg:deep_teal";
      format = "[ 󱑍 $time ]($style)";
    };

    cmd_duration = { format = "[execution time: $duration](fg:coral_pink )"; };
  };
}
