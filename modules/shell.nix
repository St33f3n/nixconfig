# shell.nix - Terminal & CLI Tools

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.shell = {
    enable = mkEnableOption "modern shell tools and utilities";
  };

  config = mkIf config.shell.enable {
    environment.systemPackages = with pkgs; [
      # Terminal Emulator
      alacritty

      # Modern Shell Stack
      nushell
      starship
      atuin
      carapace
      fzf

      # CLI Tools
      yazi
      eza
      fd
      zoxide
      dust
      direnv
      ripgrep
      bat
      jq

      # Terminal Multiplexer
      zellij

      # Task Scheduler
      pueue

      # Editors
      helix
      nano

      # System Monitoring
      btop
      nvtopPackages.full

      # System Info & Documentation
      fastfetch
      tealdeer

      # Media Tools
      yt-dlp
      ffmpegthumbnailer

      # Document Processing
      pandoc
      haskellPackages.pandoc-crossref

      # File Tools
      exfatprogs
    ];
  };
}
