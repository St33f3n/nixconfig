# modules/creative.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.creative = {
    enable = mkEnableOption "creative and design tools";
  };

  config = mkIf config.creative.enable {
    environment.systemPackages = with pkgs; [
      # 3D Design & CAD
      openscad
      freecad
      blender
      
      # Electronics Design
      kicad
      
      # 3D Printing
      orca-slicer
      
      # Video Production
      obs-studio
      
      # Audio Production
      ardour
      
      # Graphics & Image Editing
      gimp-with-plugins
      libresprite
    ];
  };
}
