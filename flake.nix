{
  description = "My personal NixOS configs";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    nixpkgs-unstable.url = github:NixOS/nixpkgs/master;

    nixos-hardware.url = github:nixos/nixos-hardware/master;
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = github:nix-community/home-manager/release-21.11;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-compat-ci.url = "github:hercules-ci/flake-compat-ci";
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-unstable, nixos-hardware, flake-compat, flake-compat-ci }: {
    nixosConfigurations.jongepad = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        nixpkgs.nixosModules.notDetected
        nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
        ./hardware-configurations/jongepad-x13-yoga.nix
        ./system-modules/pipewire.nix
        ./system-modules/binary-cache-cyberus.nix
        ./system-modules/binary-cache-iohk.nix
        ./system-modules/binary-cache-obelisk.nix
        ./system-modules/desktop.nix
        ./system-modules/flakes.nix
        ./system-modules/make-linux-fast-again.nix
        ./system-modules/nix-service.nix
        ./system-modules/printing.nix
        ./system-modules/virtualization.nix
        ./system-modules/yubikey.nix
        ./system-modules/nixbuild.nix
        (
          { pkgs, config, ... }: {

            boot.loader.systemd-boot.enable = true;
            boot.loader.systemd-boot.configurationLimit = 3;
            boot.loader.efi.canTouchEfiVariables = true;
            boot.initrd.luks.devices.crypted = {
              allowDiscards = true;
              device = "/dev/nvme0n1p2";
              preLVM = true;
            };
            #boot.kernelPackages = pkgs.linuxPackages_latest;
            boot.kernelParams = [ "intel_idle.max_cstate=4" ];
            boot.cleanTmpDir = true;

            console = {
              font = "Lat2-Terminus16";
              keyMap = "us";
            };

            environment.systemPackages = with pkgs; [ git vim wget ];

            hardware.enableAllFirmware = true;
            hardware.cpu.intel.updateMicrocode = true;

            i18n.defaultLocale = "en_US.UTF-8";

            networking.hostName = "jongepad";
            networking.firewall.logRefusedConnections = false;
            networking.networkmanager.enable = true;

            nixpkgs.config.allowUnfree = true;

            programs.bash.enableCompletion = true;

            services.avahi.enable = true;
            services.fwupd.enable = true;
            services.openssh.enable = true;

            system.stateVersion = "20.09";

            users.users.tfc = {
              isNormalUser = true;
              extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
            };
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

    ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
      flake = self;
      systems = [ "x86_64-linux" ];
    };
  };
}
