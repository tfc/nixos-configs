{ pkgs, config, self, flakeInputs, ... }:

{
  imports = [
    self.nixosModules.flakes
    self.nixosModules.remote-deployable
    self.nixosModules.simple-timers
    self.nixosModules.user-tfc
    flakeInputs.home-manager.nixosModules.home-manager
    ./ai.nix
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;
  };
  networking.hostName = "work";
  networking.networkmanager.enable = true;

  boot.kernelParams = [
    "rtl8821ae.ips=0"
    "rtl8821ae.aspm=0"
  ];

  powerManagement.cpuFreqGovernor = "performance";

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    xkb.layout = "us";
    xkb.options = "eurosign:e,caps:escape";
  };

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

  services.openssh.enable = true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  system.stateVersion = "24.11";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.tfc = { ... }: {
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
    imports = with self.homeManagerModules; [
      obs
      gnome
      desktop
      programming-haskell
      programming
      shell-bash
      shelltools
      vim
      tmux
      ssh
    ];
  };
}
