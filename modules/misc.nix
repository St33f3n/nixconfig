# modules/misc.nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.misc = {
    enable = mkEnableOption "miscellaneous utilities and tools";
  };

  config = mkIf config.misc.enable {
    environment.systemPackages = with pkgs; [
      # Game Streaming
      moonlight-qt
      sunshine
      libnfc
      pcsc-tools
      arduino
      usb-modeswitch
      usb-modeswitch-data
      # Backup Tools
      vorta
    ];

    services.udev.packages = [ pkgs.usb-modeswitch-data ];

    services.pcscd.enable = true;
    services.pcscd.plugins = with pkgs; [
      ccid
    ];
  };

}
