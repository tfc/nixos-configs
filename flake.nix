{
  description = "My personal NixOS configs";

  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    hercules-ci.url = "github:hercules-ci/hercules-ci-agent";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , darwin
    , disko
    , hercules-ci
    , home-manager
    , nixos-hardware
    , nixpkgs
    }:
    let
      modulesFromDir =
        let
          inherit (nixpkgs) lib;
          getNixFilesInDir = dir: builtins.filter
            (file: lib.hasSuffix ".nix" file && file != "default.nix")
            (builtins.attrNames (builtins.readDir dir));
          genKey = str: lib.replaceStrings [ ".nix" ] [ "" ] str;
          moduleFrom = dir: str: { "${genKey str}" = "${dir}/${str}"; };
        in
        dir:
        builtins.foldl' (x: y: x // (moduleFrom dir y)) { } (getNixFilesInDir dir);
      createConfigurations = hostSet:
        let
          items = builtins.attrValues (builtins.mapAttrs (hostName: set: set // { inherit hostName; }) hostSet);
          inherit (nixpkgs.lib) hasSuffix;
          nixItems = builtins.filter (x: hasSuffix "linux" x.system) items;
          darwinItems = builtins.filter (x: hasSuffix "darwin" x.system) items;

          createConfigAttr = systemFunction: item: {
            name = item.hostName;
            value = systemFunction {
              inherit (item) system;
              modules = [ (./hosts + "/${item.hostName}/configuration.nix") ]
                ++ item.modules;
            };
          };
          createNixosConfigAttr = createConfigAttr nixpkgs.lib.nixosSystem;
          createDarwinConfigAttr = createConfigAttr darwin.lib.darwinSystem;

          mapToAttrs = f: attrList: builtins.listToAttrs (map f attrList);
        in
        {
          nixosConfigurations = mapToAttrs createNixosConfigAttr nixItems;
          darwinConfigurations = mapToAttrs createDarwinConfigAttr darwinItems;
        };

      hosts = {
        jongepad = {
          system = "x86_64-linux";
          modules = [
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
            self.nixosModules.steam
            self.nixosModules.user-tfc
            self.nixosModules.virtualization
            self.nixosModules.yubikey
            home-manager.nixosModules.home-manager
            (_: {
              boot.plymouth.enable = true;
              customization.gdm-logo.enable = true;
              customization.gnome-background.enable = true;
              customization.plymouth-logo.enable = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tfc = { ... }: {
                home.stateVersion = "22.11";
                programs.home-manager.enable = true;
                imports = with self.homeManagerModules; [
                  gnome
                  programming-haskell
                  programming
                  shell-bash
                  shelltools
                  vim
                  yubikey
                ];
              };
              nixpkgs.config.permittedInsecurePackages = [
                "electron-21.4.0"
              ];
            })
          ];
        };
        work = {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.binary-cache-iohk
            self.nixosModules.desktop
            self.nixosModules.dontsleep
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
            self.nixosModules.steam
            self.nixosModules.user-tfc
            self.nixosModules.virtualization
            self.nixosModules.virtualbox
            home-manager.nixosModules.home-manager
            (_: {
              boot.plymouth.enable = true;
              customization.gdm-logo.enable = true;
              customization.gnome-background.enable = true;
              customization.plymouth-logo.enable = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tfc = { ... }: {
                home.stateVersion = "24.11";
                programs.home-manager.enable = true;
                imports = with self.homeManagerModules; [
                  gnome
                  programming
                  programming-haskell
                  shell-bash
                  shelltools
                  vim
                  vscode
                ];
              };
              nixpkgs.config.permittedInsecurePackages = [
                "electron-21.4.0"
              ];
            })
          ];
        };
        build01 = {
          system = "x86_64-linux";
          modules = [
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
                imports = with self.homeManagerModules; [
                  programming-haskell
                  programming
                  shell-bash
                  shelltools
                  vim
                ];
              };
            })
          ];
        };

        jongebook = {
          system = "aarch64-darwin";
          modules = [
            home-manager.darwinModules.home-manager
            (_: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tfc = { ... }: {
                home.stateVersion = "23.11";
                programs.home-manager.enable = true;
                imports = with self.homeManagerModules; [
                  programming-haskell
                  programming
                  shell-zsh
                  shelltools
                  vim
                  tmux
                  ssh
                ];
              };
            })
          ];
        };
      };
    in
      createConfigurations hosts //
    {
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = with self.homeManagerModules; [
          ({
            home.stateVersion = "23.11";
            home.username = "tfc";
            home.homeDirectory = "/home/tfc";
            programs.home-manager.enable = true;
          })
          programming-haskell
          programming
          shell-zsh
          shelltools
          vim
          tmux
          ssh
        ];
      };

      nixosModules = modulesFromDir ./system-modules;
      homeManagerModules = modulesFromDir ./home-manager-modules;

      apps =
        let
          cmd = arch: cmdStr: {
            "${arch}".default = {
              type = "app";
              program = builtins.toString (nixpkgs.legacyPackages.${arch}.writeShellScript "activate" cmdStr);
            };
          };
          forArchs = archs: system: cmdStr:
            map (arch: cmd "${arch}-${system}" cmdStr) archs;
          linux = forArchs [ "x86_64" "aarch64" ] "linux" "sudo nixos-rebuild switch --flake .";
          darwin = forArchs [ "x86_64" "aarch64" ] "darwin" "darwin-rebuild switch --flake .";
        in
        builtins.foldl' nixpkgs.lib.mergeAttrs { } (linux ++ darwin);
    };
}
