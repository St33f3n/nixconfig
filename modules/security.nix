# security.nix - Security & Privacy

{ config, lib, pkgs, ... }:

with lib;

{
  options.security = {
    enable = mkEnableOption "security and privacy tools";
  };

  config = mkIf config.security.enable {
    environment.systemPackages = with pkgs; [
      # Password Management
      keepassxc

      # Encryption & Security
      rustdesk
      picocrypt
      veracrypt

      # VPN
      protonvpn-gui
      wireguard-go

      # Secrets Management
      sops

      # Backup Tools
      borgbackup
      vorta
      zip
    ];

      # SSH Konfiguration
  services.openssh.settings = {
    PasswordAuthentication = true;
    KbdInteractiveAuthentication = false;
  };

  };
}