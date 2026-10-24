{
  pkgs,
  flakeInputs,
  self,
  ...
}:

{

  imports = [
    self.nixosModules.flakes
    self.nixosModules.make-linux-fast-again
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
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
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

  services.openssh.enable = true;

  users.users.tfc = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
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
