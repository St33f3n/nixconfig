# modules/server.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.server = {
    enable = mkEnableOption "server services and tools";
  };

  config = mkIf config.server.enable {
    environment.systemPackages = with pkgs; [
      samba
      vsftpd
    ];
    
    # Basic service configurations - enable as needed
    services.samba = {
      enable = false;  # Set to true and configure when needed
      # package = pkgs.samba4Full;
    };
    
    services.vsftpd = {
      enable = false;  # Set to true and configure when needed
    };
  };
}
