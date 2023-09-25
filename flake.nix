{
  description = "My personal NixOS configs";

  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    hercules-ci.url = "github:hercules-ci/hercules-ci-agent";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs =
    { self
    , disko
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
          self.nixosModules.nix-unstable
          self.nixosModules.nixcademy-gdm-logo
          self.nixosModules.nixcademy-gnome-background
          self.nixosModules.nixcademy-plymouth-logo
          self.nixosModules.pipewire
          self.nixosModules.printing
          self.nixosModules.remote-builds
          self.nixosModules.user-tfc
          self.nixosModules.virtualization
          self.nixosModules.yubikey
          home-manager.nixosModules.home-manager
          (_: {
            boot.plymouth.enable = true;
            customization.gdm-logo.enable = true;
            customization.plymouth-logo.enable = true;
            customization.gnome-background.enable = true;
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
            nixpkgs.config.permittedInsecurePackages = [
              "electron-21.4.0"
            ];
          })
        ];
      };

      nixosConfigurations."build01" = nixpkgs.lib.nixosSystem rec {
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
          self.nixosModules.save-space
          self.nixosModules.user-tfc
          (_: {
            imports = [ hercules-ci.nixosModules.agent-profile ];
            services.hercules-ci-agent.enable = true;
            services.hercules-ci-agent.settings.concurrentTasks = 4;
          })
          home-manager.nixosModules.home-manager
          (_: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.tfc = { ... }: {
              home.stateVersion = "22.11";
              programs.home-manager.enable = true;
              imports = [
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

      nixosConfigurations."build02" = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        modules = [
          ./hosts/build02/configuration.nix
          nixpkgs.nixosModules.notDetected
          disko.nixosModules.disko
          self.nixosModules.auto-upgrade
          self.nixosModules.binary-cache-iohk
          self.nixosModules.firmware
          self.nixosModules.flakes
          self.nixosModules.make-linux-fast-again
          self.nixosModules.nix-service
          self.nixosModules.remote-deployable
          self.nixosModules.save-space
          self.nixosModules.user-tfc
          (_: {
            imports = [ hercules-ci.nixosModules.agent-profile ];
            services.hercules-ci-agent.enable = true;
            services.hercules-ci-agent.settings.concurrentTasks = 2;
          })
          home-manager.nixosModules.home-manager
          (_: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.tfc = { ... }: {
              home.stateVersion = "22.11";
              programs.home-manager.enable = true;
              imports = [
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
