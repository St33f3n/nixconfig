# misc.nix - Miscellaneous Applications

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
      # Audio & Bluetooth
      noisetorch
      pavucontrol
      bluez
      bluez-tools
      bluez-alsa

      # Browsers
      mullvad-browser

      # Media & Entertainment
      calibre
      spotify
      libation
      celluloid

      # Hardware Tools
      via
    ];
  };
}
