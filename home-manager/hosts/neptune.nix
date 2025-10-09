# Workstation-spezifische Konfiguration (Dual-GPU)
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../profiles/base.nix
    ../profiles/desktop.nix
  ];

  home.sessionVariables = {
    # AMD GPU als primär
    ROCR_VISIBLE_DEVICES = "0";
    HIP_VISIBLE_DEVICES = "0";
    HSA_OVERRIDE_GFX_VERSION = "11.0.1";

    # Wayland Desktop
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
}
