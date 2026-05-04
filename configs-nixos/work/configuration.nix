{
  pkgs,
  lib,
  self,
  flakeInputs,
  ...
}:

{
  imports = [
    self.nixosModules.flakes
    self.nixosModules.make-linux-fast-again
    self.nixosModules.nix-service
    self.nixosModules.nix-unstable
    self.nixosModules.remote-deployable
    self.nixosModules.simple-timers
    self.nixosModules.steam
    self.nixosModules.user-tfc
    self.nixosModules.virtualization
    self.nixosProfiles.applicative-systems-customization
    flakeInputs.home-manager.nixosModules.home-manager
    flakeInputs.medusa.nixosModules.medusa-builder
    ./ai.nix
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  nixpkgs.overlays = [
    self.overlays.default
    flakeInputs.medusa.overlays.default
  ];

  services.medusa-builder = {
    enable = true;
    medusaHost = "medusa.nix-consulting.net";
    medusaPort = 45678;
    enrollmentTokenFile = "/tmp/medusa-token";
  };

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;
  };
  networking.hostName = "work";
  networking.networkmanager.enable = true;
  boot.initrd.systemd.enable = true;

  boot.kernelParams = [
    "rtl8821ae.ips=0"
    "rtl8821ae.aspm=0"
  ];

  powerManagement.cpuFreqGovernor = "balanced";

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.options = "eurosign:e,caps:escape";
  };
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.tfc = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  programs.dconf.profiles.gdm.databases = [{
    settings."org/gnome/desktop/interface".scaling-factor = lib.gvariant.mkUint32 2;
  }];

  services.openssh.enable = true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  system.stateVersion = "24.11";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.tfc = {
      home.stateVersion = "23.11";
      programs.home-manager.enable = true;
      imports = with self.homeManagerModules; [
        desktop
        gnome
        obs
        programming
        programming-haskell
        shell-bash
        shelltools
        ssh
        tmux
        vim
        vscode
      ];
    };
  };
}
