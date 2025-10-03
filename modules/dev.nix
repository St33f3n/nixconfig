# dev.nix - Development Tools

{ config, lib, pkgs, ... }:

with lib;

{
  options.dev = {
    enable = mkEnableOption "development tools and language servers";
  };

  config = mkIf config.dev.enable {
    environment.systemPackages = with pkgs; [
      # Version Control
      git
      lazygit

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
      home-manager

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
      python312Packages.python-lsp-server
      hyprls
      pyright
      gopls
      bash-language-server
      ruff
      cuelsp

      # Programming Languages & Runtimes
      rustup
      uv
      nodejs_24
      julia-lts
      bun
      dart
      alire

      # Development Tools
      bacon
      lldb
      scc
      cue
      cuetools
      docker-credential-helpers

      # Development Environments & IDEs
      arduino-ide
      godot
      vscode-fhs

      # Database Administration Tools
      sqlitebrowser
      pgadmin4-desktopmode

      # Automation & System Tools
      ansible
      scrcpy
      keymapp

      # Hardware Development
      arduino
      libnfc
      pcsc-tools
      usb-modeswitch
      usb-modeswitch-data
    ];

    # Hardware Services
    services.udev.packages = [ pkgs.usb-modeswitch-data ];
    services.pcscd = {
      enable = true;
      plugins = with pkgs; [ ccid ];
    };
  };
}