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
            boot.kernelPackages = pkgs.linuxPackages_latest;
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

    nixosConfigurations.jonge-x250 = nixpkgs-unstable.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        nixpkgs.nixosModules.notDetected
        nixos-hardware.nixosModules.lenovo-thinkpad-x250
        ./hardware-configurations/jonge-x250.nix
        ./system-modules/dontsleep.nix
        ./system-modules/gitlab-runner.nix
        ./system-modules/hercules.nix
        ./system-modules/make-linux-fast-again.nix
        ./system-modules/nix-service.nix
        ./system-modules/remote-deployable.nix
        ({ pkgs, ... }: {
          boot.cleanTmpDir = true;

          boot.loader.grub.enable = true;
          boot.loader.grub.efiSupport = true;
          boot.loader.grub.device = "nodev";
          boot.loader.grub.configurationLimit = 3;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.kernelPackages = pkgs.linuxPackages_latest;

          console.keyMap = "us";

          environment.systemPackages = with pkgs; [ git vim wget ];

          hardware.enableAllFirmware = true;

          i18n.defaultLocale = "en_US.UTF-8";

          networking.hostName = "jonge-x250";
          networking.firewall.logRefusedConnections = false;
          networking.wireless = {
            enable = true;
            interfaces = [ "wlp3s0" ];
            networks = {
              "Trafo Hub Member".psk = "@PASS_TRAFO@";
              "jongenet".psk = "@PASS_JONGENET@";
            };
            environmentFile = "/var/secrets/wireless.env";
            userControlled.enable = true;
          };

          nix.optimise.automatic = true;
          nix.gc = {
            automatic = true;
            options = "--max-freed 40G";
          };

          nixpkgs.config.allowUnfree = true;
          time.timeZone = "Europe/Berlin";

          services.openssh.enable = true;

          system.stateVersion = "20.03";

          users.users.tfc = {
            isNormalUser = true;
            extraGroups = [ "wheel" "libvirtd" ];
            openssh.authorizedKeys.keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXfQnzmqFQsUPwJm1sQSh2A7HH1YxO6OOOn1r2QR/PqwVIRu1rOzAC5IXPKmaIN770dLIJzQMqQoUr3ih/x+zweEyUqJTP0sIjA8l9lJNj0S6xVZ594ci/C6w9fR9uKRmXIk7r6usaqTF0Jdf02Al0tB0Lv4Aqi2b6VNPLO3LT162ZuRpcqSDIZzmQg+lkd0s1jWnJGdX5s7G959ouvID5xx7g/e31M/p4PJFvdEtmZ0YGTqju+STyOvX56GvQKRlRRYVFwwTyC1KUr0fJ31dM0DjZoIrfbeY+MBO6JXT23x6iU2sywqxmrDrRphu3raLI/Y2PhopO0q7DutAoolgV cardno:000606444835"
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBOn2J1U52OfEUNXbUDtOFT2vCH9nOJBmSvRFkkkgbl3tiEHwyw2VRsykOTxbMXPjXCCski3CZA1CMeL/g/u3TEyA1797eOs+bgCWCo1QvH7//45v7791oA72XmaUwvmXpf8lZM4d1EkQkGwtv2lPp3yth8p+8P9Hx8S7rMZBZQSjQ7ME3liQVjz8Lu0z3sd+InywnysaYxGrfqkGEEM3/j+RruY85/f8UIxnoPw3ehjbI9cjYyGjtjs+h4RpVt5q2d6hOTMKvXz0HZ2q+KOKbsfgZgeeFReez3lTuVD5FaoLT+21PXTEJK5L8qr9XsWLkmfZGK1iri9h/xXG2+1ST cardno:000609623790"
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
