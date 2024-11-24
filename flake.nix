{
  description = "My personal NixOS configs";

  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    sysmodule-flake.url = "/Users/tfc/src/asg/sysmodule-flake"; #"github:applicative-systems/sysmodule-flake";
    sysmodule-flake.inputs.nixpkgs.follows = "nixpkgs";
    sysmodule-flake.inputs.flake-parts.follows = "flake-parts";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
    imports = [
      inputs.sysmodule-flake.flakeModules.default
    ];
    sysmodules-flake = {
      modulesPath = ./.;
      specialArgs.self = inputs.self;
      nix-darwin = inputs.darwin;
    };
    debug = true;
  };
}
