{
    nixConfig = {
        extra-substituters =  ["https://nix-community.cachix.org"];
        extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    };    
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

        snowfall-lib = {
            url = "github:snowfallorg/lib";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix/master";
    };

    outputs = inputs:
        inputs.snowfall-lib.mkFlake {
            inherit inputs;
            channels-config = {
                crossSystem.system = "aarch64-unknown-linux-gnu";
            };
            src = ./.;
        };
}
