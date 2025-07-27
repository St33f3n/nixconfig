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

      # Backup Tools
      vorta
    ];
  };
}
