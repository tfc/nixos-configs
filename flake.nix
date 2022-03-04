{
  description = "My personal NixOS configs";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    nixpkgs-unstable.url = github:NixOS/nixpkgs/master;

    nixos-hardware.url = github:nixos/nixos-hardware/master;
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = github:rycee/home-manager/release-21.11;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-unstable, nixos-hardware }: {
    nixosConfigurations.jongepad = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        nixpkgs.nixosModules.notDetected
        nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
        home-manager.nixosModules.home-manager
        ./hardware-configurations/jongepad-x13-yoga.nix
        ./modules/pipewire.nix
        ./modules/binary-cache-cyberus.nix
        ./modules/binary-cache-iohk.nix
        ./modules/binary-cache-obelisk.nix
        ./modules/desktop.nix
        ./modules/flakes.nix
        ./modules/make-linux-fast-again.nix
        ./modules/nix-service.nix
        ./modules/printing.nix
        ./modules/virtualization.nix
        ./modules/yubikey.nix
        ./modules/nixbuild.nix
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
      ];
    };
  };
}
