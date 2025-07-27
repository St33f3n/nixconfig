# modules/dev.nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.dev = {
    enable = mkEnableOption "development tools and language servers";
  };

  config = mkIf config.dev.enable {
    environment.systemPackages = with pkgs; [
      # Nix Development Tools
      nix-tree
      nix-du
      nixpkgs-review
      manix
      statix
      deadnix
      nix-prefetch-git
      nix-prefetch-hg
      nix-ld
      nixfmt-rfc-style

      # Language Servers
      nixd
      nil
      typescript-language-server
      taplo
      yaml-language-server
      openscad-lsp
      llvmPackages_20.clang-tools
      marksman
      rust-analyzer
      python311Packages.python-lsp-server
      ruff
      black
      ruff
      hyprls
      gopls
      bash-language-server

      # Programming Language Runtimes & Package Managers
      nodejs_24
      julia-lts
      uv
      bun
      dart
      alire

      # Development Environments & IDEs
      arduino-ide
      godot
      vscode-fhs

      # Automation & System Tools
      ansible
      scrcpy
      keymapp

      # Language-Specific Tools
      bacon # Rust background compiler
      lldb # Debug adapter
      ruff # Python linter/formatter
    ];
  };
}
