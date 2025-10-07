# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  quickshellConfig = "default.qml";
in
{

  imports = [
    ../git.nix
    ../shell.nix
    ../helix.nix
  ];

  home = {
    username = "biocirc";
    homeDirectory = "/home/biocirc";
    sessionVariables = {
      BROWSER = "librewolf";
      EDITOR = "hx";
      SHELL = "nu";
    };
    file = {
      "p/active/.keep".text = "";
      "p/done/.keep".text = "";
      "a/dev/.keep".text = "";
      "a/finance/.keep".text = "";
      "a/sys/.keep".text = "";
      "a/work/.keep".text = "";
      "r/books/.keep".text = "";
      "r/courses/.keep".text = "";
      "r/pics/.keep".text = "";
      "r/wall/.keep".text = "";
      "r/docs/.keep".text = "";
      "r/dl/.keep".text = "";
      "bin/.keep".text = "";
      "tmp/.keep".text = "";
    };
    sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
    };
  };

  xdg.userDirs = {
    enable = true;

    desktop = "$HOME/tmp";
    documents = "$HOME/r/docs";
    download = "$HOME/r/dl";
    pictures = "$HOME/r/pics";
    videos = "$HOME/r/videos";
    music = "$HOME/r/music";
    templates = "$HOME/r/templates";
  };


  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "pkcs11"
    ];
  };

  
  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
