{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        snowfall-lib = {
            url = "github:snowfallorg/lib";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        coffeeispower-nix-config = {
            url = "github:coffeeispower/nix-configuration";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.home-manager.follows = "home-manager";
            inputs.stylix.follows = "stylix";
        };
        
        drupal-website = {
            url = "github:coffeeispower/my-drupal-site";
        };
        stylix = {
          url = "github:danth/stylix/master";
          inputs.home-manager.follows = "home-manager";
          inputs.nixpkgs.follows = "nixpkgs";
        };

    };

    outputs = inputs:
        let
            snowfall = inputs.snowfall-lib.mkLib {
                inherit inputs;
                src = ./.;
            };
        in
        snowfall.mkFlake {
            homes.modules = with inputs.coffeeispower-nix-config.homeModules; [
                helix
                nushell
                git
                gh
                fastfetch
                direnv
                zoxide
            ];
            systems.modules.nixos = with inputs.coffeeispower-nix-config.nixosModules; [
                stylix
                inputs.stylix.nixosModules.stylix
            ];
        };
}
