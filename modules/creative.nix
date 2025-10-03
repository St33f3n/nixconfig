# creative.nix - Creative Tools

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.creative = {
    enable = mkEnableOption "creative and design tools";
  };

  config = mkIf config.creative.enable {
    environment.systemPackages = with pkgs; [
      # 3D Design & CAD
      openscad
      blender

      # Electronics Design
      kicad
      orca-slicer

      # Video Production
      obs-studio

      # Audio Production
      ardour

      # Graphics & Image Editing
      gimp3-with-plugins
      libresprite
    ];
  };
}
