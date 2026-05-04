{
  description = "My personal NixOS configs";

  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    medusa.url = "git+ssh://git@github.com/tfc/argunix";
    medusa.inputs.nixpkgs.follows = "nixpkgs";
    medusa.inputs.flake-parts.follows = "flake-parts";

    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    sysmodule-flake.url = "github:applicative-systems/sysmodule-flake";
    sysmodule-flake.inputs.nixpkgs.follows = "nixpkgs";
    sysmodule-flake.inputs.flake-parts.follows = "flake-parts";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      imports = [
        inputs.sysmodule-flake.flakeModules.default
      ];
      sysmodules-flake = {
        modulesPath = ./.;
        specialArgs.self = inputs.self;
        nix-darwin = inputs.darwin;
      };

      flake = {
        overlays.default = import ./packages;
      };

      perSystem =
        { system, pkgs, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.self.overlays.default ];
          };
          formatter = pkgs.nixfmt;

          packages = {
            inherit (pkgs)
              claude-top
              claude-top-sound
              play-ready-sound
              ;
          };
        };
    };
}
