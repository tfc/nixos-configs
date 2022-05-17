{
  description = "My personal NixOS configs";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    nixpkgs-unstable.url = github:NixOS/nixpkgs/master;

    nixos-hardware.url = github:nixos/nixos-hardware/master;
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = github:nix-community/home-manager/release-21.11;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hercules-ci-agent.url = github:hercules-ci/hercules-ci-agent/master;
  };

  outputs =
    { self
    , hercules-ci-agent
    , home-manager
    , nixos-hardware
    , nixpkgs
    , nixpkgs-unstable
    }: {
      nixosConfigurations.jongepad = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/jongepad/hardware-configuration.nix
          ./hosts/jongepad/configuration.nix
          nixpkgs.nixosModules.notDetected
          nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
          self.nixosModules.binary-cache-cyberus
          self.nixosModules.binary-cache-iohk
          self.nixosModules.binary-cache-obelisk
          self.nixosModules.desktop
          self.nixosModules.firmware
          self.nixosModules.flakes
          self.nixosModules.make-linux-fast-again
          self.nixosModules.netdata
          self.nixosModules.nix-service
          self.nixosModules.pipewire
          self.nixosModules.printing
          self.nixosModules.user-tfc
          self.nixosModules.virtualization
          self.nixosModules.yubikey
          ({ ... }:
            let
              pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
              overlay = final: prev: {
                sof-firmware = pkgsUnstable.sof-firmware;
              };
            in
            {
              nixpkgs.overlays = [ overlay ];
            }
          )
          home-manager.nixosModules.home-manager
          (_: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.tfc = { ... }: {
              programs.home-manager.enable = true;
              imports = [
                ./home-manager-modules/gnome.nix
                ./home-manager-modules/programming-haskell.nix
                ./home-manager-modules/programming.nix
                ./home-manager-modules/shell/bash.nix
                ./home-manager-modules/shelltools.nix
                ./home-manager-modules/yubikey.nix
              ];
            };
          })
        ];
      };

      nixosConfigurations.jonge-x250 = nixpkgs-unstable.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/jonge-x250/hardware-configuration.nix
          ./hosts/jonge-x250/configuration.nix
          hercules-ci-agent.nixosModules.agent-service
          nixos-hardware.nixosModules.lenovo-thinkpad-x250
          nixpkgs.nixosModules.notDetected
          self.nixosModules.auto-upgrade
          self.nixosModules.dontsleep
          self.nixosModules.firmware
          self.nixosModules.gitlab-runner
          self.nixosModules.make-linux-fast-again
          self.nixosModules.netdata
          self.nixosModules.remote-deployable
          self.nixosModules.user-tfc
          home-manager.nixosModules.home-manager
          (_: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.tfc = { ... }: {
              programs.home-manager.enable = true;
              imports = [
                ./home-manager-modules/programming.nix
                ./home-manager-modules/shell/bash.nix
                ./home-manager-modules/shelltools.nix
              ];
            };
          })

        ];
      };

      nixosConfigurations.qssep = nixpkgs-unstable.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/qssep/hardware-configuration.nix
          ./hosts/qssep/configuration.nix
          nixpkgs.nixosModules.notDetected
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          self.nixosModules.auto-upgrade
          self.nixosModules.netdata
          self.nixosModules.remote-deployable
          self.nixosModules.user-tfc
        ];
      };

      nixosModules =
        let
          inherit (nixpkgs) lib;
          getNixFilesInDir = dir: builtins.filter
            (file: lib.hasSuffix ".nix" file && file != "default.nix")
            (builtins.attrNames (builtins.readDir dir));
          genKey = str: lib.replaceStrings [ ".nix" ] [ "" ] str;
          moduleFrom = dir: str: { "${genKey str}" = "${dir}/${str}"; };
          modulesFromDir = dir: builtins.foldl' (x: y: x // (moduleFrom dir y)) { } (getNixFilesInDir dir);
        in
        modulesFromDir ./system-modules;
    };
}
