# Laptop-spezifische Konfiguration
{ pkgs, lib, inputs, ... }:
{
  imports = [
    ../profiles/base.nix
    ../profiles/desktop.nix
  ];

  home.sessionVariables = {
    # Laptop braucht Hardware-Cursor-Workaround
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
}