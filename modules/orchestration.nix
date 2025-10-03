# orchestration.nix - Network Tools & Infrastructure Management

{ config, lib, pkgs, ... }:

with lib;

{
  options.orchestration = {
    enable = mkEnableOption "network tools and infrastructure management";
  };

  config = mkIf config.orchestration.enable {
    environment.systemPackages = with pkgs; [
      # Network Tools
      ethtool
      inotify-tools
      inotify-info
      nmap
      netcat
      nettools
      wakeonlan
      dnsmasq
      bridge-utils
      nethogs
    ];
  };
}