{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #Flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    espanso-fix.url = "github:pitkling/nixpkgs/espanso-fix-capabilities-export";

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      nix-flatpak,
      zen-browser,
      sops-nix,
      quickshell,
      espanso-fix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "x86_64-linux"
      ];

      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);


      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = {
        triton = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            # > Our main nixos configuration file <
            ./machines/triton/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit inputs outputs; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.biocirc = import ./home-manager/hosts/triton.nix;
            }
            stylix.nixosModules.stylix
            nix-flatpak.nixosModules.nix-flatpak
          ];
        };

        neptune = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            # > Our main nixos configuration file <
            ./machines/neptune/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit inputs outputs; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.biocirc = import ./home-manager/hosts/neptune.nix;
            }
            espanso-fix.nixosModules.espanso-capdacoverride
            stylix.nixosModules.stylix
            nix-flatpak.nixosModules.nix-flatpak
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
