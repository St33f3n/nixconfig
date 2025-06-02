# modules/shell.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.shell = {
    enable = mkEnableOption "modern shell tools and utilities";
  };

  config = mkIf config.shell.enable {
    environment.systemPackages = with pkgs; [
      # Modern Shell Stack
      nushell
      starship
      atuin
      carapace
      
      # Terminal Multiplexer & Task Management
      zellij
      pueue
      
      # Document Processing
      pandoc
      pandoc-crossref
      
      # Media & File Tools
      yt-dlp
      exfat-progs
    ];
  };
}
