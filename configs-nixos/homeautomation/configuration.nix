{
  pkgs,
  flakeInputs,
  self,
  ...
}:

{

  imports = [
    self.nixosModules.flakes
    self.nixosModules.remote-deployable
    self.nixosModules.simple-timers
    self.nixosModules.user-tfc
    flakeInputs.home-manager.nixosModules.home-manager
    flakeInputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./ha.nix
    #./grafana.nix
  ];

  hardware.raspberry-pi.firmware = {
    enable = true;
    uboot.enable = true;
    # The full firmware package (boot code for all Pi models) doesn't fit on the
    # 30M FIRMWARE partition of older SD images, so only ship what the Pi 4 needs.
    package = pkgs.runCommand "raspberrypi-firmware-pi4" { } ''
      src=${pkgs.raspberrypifw}/share/raspberrypi/boot
      dst=$out/share/raspberrypi/boot
      mkdir -p $dst
      cp -r $src/{bootcode.bin,start4.elf,fixup4.dat,bcm2711-rpi-4-b.dtb,overlays} $dst/
    '';
  };

  boot.kernelParams = [ "cma=256M" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "noatime"
        "nofail"
      ];
    };
  };

  networking = {
    hostName = "homeautomation";
    firewall.enable = false;
    wireless = {
      enable = true;
      secretsFile = "/var/secrets/wifi";
      networks.jongenet.pskRaw = "ext:jacek_home";
      interfaces = [ "wlan0" ];
    };
  };

  environment.systemPackages = with pkgs; [
    tmux
    unzip
    vim
    zip
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.overwriteBackup = true;
  home-manager.users.tfc = {
    home.stateVersion = "22.11";
    programs.home-manager.enable = true;
    imports = with self.homeManagerModules; [
      shell-bash
      shelltools
      vim
    ];
  };
}
