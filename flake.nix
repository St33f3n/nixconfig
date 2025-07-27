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

    
    #Stylix
    stylix.url = "github:danth/stylix";

    #Flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Zen-browser
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    stylix,
    nix-flatpak,
    zen-browser,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
    ];
    
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);



    packages.x86_64-linux= {
      zen-browser = nixpkgs.legacyPackages.x86_64-linux.callPackage ./own_pkgs/zen_browser.nix {};
    };

    
    homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = {
      triton = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./machines/triton/configuration.nix
          home-manager.nixosModules.home-manager{
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.biocirc = import ./home-manager/home.nix;
          }
          inputs.stylix.nixosModules.stylix
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };

      neptune_virt = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./machines/neptune-virt/configuration.nix
          home-manager.nixosModules.home-manager{
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.biocirc = import ./home-manager/home.nix;
          }
          inputs.stylix.nixosModules.stylix
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };

  };
}
