# modules/dev.nix
{ config, lib, pkgs, ... }:

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
      clangd
      marksman
      hyprls
      gopls
      ada_language_server
      bash-language-server
      
      # Programming Language Runtimes & Package Managers
      nodejs
      juliaup
      uv
      bun
      dart
      
      # Development Environments & IDEs
      arduino-ide
      godot
      
      # Automation & System Tools
      ansible
      scrcpy
      keymapp
      
      # Language-Specific Tools
      bacon          # Rust background compiler
      lldb-dap       # Debug adapter
      ruff           # Python linter/formatter
    ];
  };
}
