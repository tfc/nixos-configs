{
  description = "My personal NixOS configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    hercules-ci.url = "github:hercules-ci/hercules-ci-agent";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , hercules-ci
    , home-manager
    , nixos-hardware
    , nixpkgs
    }: {
      nixosConfigurations.jongepad = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/jongepad/hardware-configuration.nix
          ./hosts/jongepad/configuration.nix
          nixpkgs.nixosModules.notDetected
          nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
          self.nixosModules.binary-cache-iohk
          self.nixosModules.desktop
          self.nixosModules.firmware
          self.nixosModules.flakes
          self.nixosModules.make-linux-fast-again
          self.nixosModules.nix-service
          self.nixosModules.pipewire
          self.nixosModules.printing
          self.nixosModules.user-tfc
          self.nixosModules.virtualization
          self.nixosModules.yubikey
          home-manager.nixosModules.home-manager
          (_: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.tfc = { ... }: {
              home.stateVersion = "22.11";
              programs.home-manager.enable = true;
              imports = [
                ./home-manager-modules/gnome.nix
                ./home-manager-modules/programming-haskell.nix
                ./home-manager-modules/programming.nix
                ./home-manager-modules/shell/bash.nix
                ./home-manager-modules/shelltools.nix
                ./home-manager-modules/vim.nix
                ./home-manager-modules/yubikey.nix
              ];
            };
          })
        ];
      };

      nixosConfigurations."build01.nix-consulting.de" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/build01/hardware-configuration.nix
          ./hosts/build01/configuration.nix
          nixpkgs.nixosModules.notDetected
          self.nixosModules.auto-upgrade
          self.nixosModules.binary-cache-iohk
          self.nixosModules.firmware
          self.nixosModules.flakes
          self.nixosModules.make-linux-fast-again
          self.nixosModules.nix-service
          self.nixosModules.remote-deployable
          self.nixosModules.user-tfc
          (_: {
            imports = [ hercules-ci.nixosModules.agent-profile ];
            services.hercules-ci-agent.enable = true;
            services.hercules-ci-agent.settings.concurrentTasks = 4;
          })
        ];
      };

      nixosConfigurations.jongenuc = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/jongenuc/hardware-configuration.nix
          ./hosts/jongenuc/configuration.nix
          nixpkgs.nixosModules.notDetected
          nixos-hardware.nixosModules.intel-nuc-8i7beh
          self.nixosModules.binary-cache-iohk
          self.nixosModules.desktop
          self.nixosModules.firmware
          self.nixosModules.flakes
          self.nixosModules.make-linux-fast-again
          self.nixosModules.nix-service
          self.nixosModules.pipewire
          self.nixosModules.user-tfc
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

      nixosConfigurations.jongebook = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/jongebook/hardware-configuration.nix
          ./hosts/jongebook/configuration.nix
          nixpkgs.nixosModules.notDetected
          nixos-hardware.nixosModules.apple-macbook-pro
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          self.nixosModules.binary-cache-iohk
          self.nixosModules.desktop
          self.nixosModules.firmware
          self.nixosModules.flakes
          self.nixosModules.make-linux-fast-again
          self.nixosModules.nix-service
          self.nixosModules.pipewire
          self.nixosModules.user-tfc
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
                ./home-manager-modules/vim.nix
              ];
            };
          })
        ];
      };


      nixosConfigurations.jonge-x250 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/jonge-x250/hardware-configuration.nix
          ./hosts/jonge-x250/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x250
          nixpkgs.nixosModules.notDetected
          self.nixosModules.auto-upgrade
          self.nixosModules.dontsleep
          self.nixosModules.firmware
          self.nixosModules.make-linux-fast-again
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
