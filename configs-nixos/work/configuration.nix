{ pkgs, config, flakeInputs, self, ... }:

{
  imports = [
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
    flakeInputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ./ai.nix
    ./nvidia.nix
  ];

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
      obs
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
}
