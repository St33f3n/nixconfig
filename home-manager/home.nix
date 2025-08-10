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
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    ./hyprland.nix
    ./git.nix
    ./shell.nix
    ./helix.nix
    ./rofi.nix
    ./niri.nix
    inputs.zen-browser.homeModules.beta
    #./theming.nix
  ];

  home = {
    username = "biocirc";
    homeDirectory = "/home/biocirc";
    sessionVariables = {
      EDITOR = "hx";
      SHELL = "nu";
    };
    file = {
      "p/active/.keep".text = "";
      "p/done/.keep".text = "";
      "a/dev/.keep".text = "";
      "a/fin/.keep".text = "";
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
    # weitere XDG-Dirs nach Bedarf
  };

  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "pkcs11"
    ];
  };

  programs.keepassxc = {
    enable = true;
    settings = {
      General.SingleInstance = true;
      General.MinimizeAfterUnlock = false;

      GUI = {
        LaunchAtStartup = true;
        ShowTrayIcon = true;
        ApplicationTheme = "dark";
      };
      Browser.Enabled = false;
      SSHAgent = {
        Enabled = false;
      };
      FdoSecrets = {
        Enabled = false;
        ConfirmAccessItem = false;
        ConfirmDeletItem = false;
        UnlockBeforeSearch = false;
      };
    };
  };
  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.zen-browser.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
