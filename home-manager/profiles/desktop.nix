# Desktop-Environment-Features (NUR für triton + neptune)
{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  imports = [
    ../hyprland.nix
    ../rofi.nix
  ];

  home.sessionVariables = {
    # Desktop-spezifische Variablen
    BROWSER = "librewolf";
  };

  # XDG MIME Apps (Browser-Integration)
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
      "application/pdf" = "librewolf.desktop";
      "application/x-pdf" = "librewolf.desktop";
    };
    associations.added = {
      "application/pdf" = [ "librewolf.desktop" ];
      "text/html" = [ "librewolf.desktop" ];
    };
  };
}
