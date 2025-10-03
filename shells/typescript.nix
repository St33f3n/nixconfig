# shells/typescript-nextjs.nix - Mit neuem buildFHSEnv
{
  pkgs,
  lib,
  inputs,
  ...
}:

pkgs.buildFHSEnv {
  # ← Geändert von buildFHSUserEnv
  name = "typescript-nextjs-dev";

  # Packages für die FHS-Umgebung
  targetPkgs =
    pkgs: with pkgs; [
      # Node.js ecosystem
      nodejs_24
      nodePackages.npm
      nodePackages.pnpm
      yarn

      # TypeScript tools
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.eslint
      nodePackages.prettier

      # Rust für Turbopack
      rustc
      cargo

      # System libraries für npm-installierte binaries
      stdenv.cc.cc.lib
      zlib
      openssl
      pkg-config

      # Deine shell tools
      nushell
      starship
      atuin
      carapace
      eza
      zoxide
      yazi
      helix
      fastfetch
      git
      lazygit
    ];

  # 32-bit support (optional)
  multiPkgs =
    pkgs: with pkgs; [
      stdenv.cc.cc.lib
      zlib
    ];

  # Shell script das beim Eintritt ausgeführt wird
  runScript = pkgs.writeScript "typescript-nextjs-init" ''
    #!/bin/bash

    # Home-Manager shell environment
    export EDITOR="hx"
    export SHELL="nu" 
    export NU_LIB_DIRS="./scripts"

    # Node.js development
    export NODE_ENV="development"
    export NEXT_TELEMETRY_DISABLED="1"
    export NODE_PATH="$PWD/node_modules:$NODE_PATH"

    # Turbopack - funktioniert in FHS
    export TURBOPACK=1

    # Performance
    export NODE_OPTIONS="--max-old-space-size=4096"

    # Starship config
    export STARSHIP_CONFIG="${pkgs.writeText "starship.toml" (builtins.readFile ../home-manager/starship.toml)}"

    # VSCode FHS compatibility
    export VSCODE_EXTENSIONS_PATH="$HOME/.vscode/extensions"

    echo "🚀 TypeScript/Next.js FHS Development Environment"
    echo "📦 Node.js: $(node --version)"
    echo "🔷 TypeScript: $(tsc --version)"
    echo "⚡ Turbopack: ENABLED (FHS environment)"
    echo "🐚 Shell: $(nu --version)"
    echo "📁 FHS paths: /bin, /lib, /usr available"
    echo ""
    echo "🛠️ Commands:"
    echo "  npx create-next-app@latest . --typescript --tailwind --eslint --app --turbo"
    echo "  npm run dev     # Turbopack works!"
    echo "  code-fhs ."
    echo ""

    # Auto-setup für bestehende Projekte
    if [ -f "package.json" ]; then
      echo "📄 Existing project detected"
      
      # Update scripts für Turbopack falls nötig
      if ! grep -q "next dev --turbo" package.json 2>/dev/null; then
        echo "⚡ Enabling Turbopack..."
        npm pkg set scripts.dev='next dev --turbo' 2>/dev/null || true
        npm pkg set scripts.build='next build --turbo' 2>/dev/null || true
      fi
    fi

    # Starte nushell
    exec nu
  '';
}
