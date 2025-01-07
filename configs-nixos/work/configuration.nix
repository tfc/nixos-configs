{ pkgs, config, self, flakeInputs, ... }:

{
  imports = [
    self.nixosModules.flakes
    self.nixosModules.make-linux-fast-again
    self.nixosModules.remote-deployable
    self.nixosModules.simple-timers
    self.nixosModules.user-tfc
    flakeInputs.home-manager.nixosModules.home-manager
    ./ai.nix
    ./droidcam.nix
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  networking.hostName = "work";
  networking.networkmanager.enable = true;

  powerManagement.cpuFreqGovernor = "performance";

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  hardware.pulseaudio.enable = false;
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
