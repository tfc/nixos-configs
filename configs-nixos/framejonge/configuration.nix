{
  pkgs,
  config,
  lib,
  self,
  flakeInputs,
  ...
}:
{
  imports = [
    ./disk.nix
    flakeInputs.disko.nixosModules.default
    flakeInputs.home-manager.nixosModules.home-manager
    flakeInputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    self.nixosModules.desktop
    self.nixosModules.firmware
    self.nixosModules.flakes
    self.nixosModules.nix-service
    self.nixosModules.nix-unstable
    self.nixosModules.nixcademy-gdm-logo
    self.nixosModules.nixcademy-gnome-background
    self.nixosModules.nixcademy-plymouth-logo
    self.nixosModules.pipewire
    self.nixosModules.steam
    self.nixosModules.user-tfc
    self.nixosModules.virtualization
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.tmp.cleanOnBoot = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.framework.enableKmod = true;

  boot.plymouth.enable = true;
  customization = {
    gdm-logo.enable = true;
    gnome-background.enable = true;
    plymouth-logo.enable = true;
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];
  environment.variables = {
    EDITOR = lib.mkOverride 0 "vim";
    TERM = "xterm-256color";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "framejonge";
  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;
  networking.useNetworkd = true;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  nixpkgs.config.allowUnfree = true;

  services.fwupd.enable = true;
  services.openssh.enable = true;

  services.tailscale.enable = true;
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  system.stateVersion = "25.05";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.tfc =
    { ... }:
    {
      home.stateVersion = "25.05";
      programs.home-manager.enable = true;
      imports = with self.homeManagerModules; [
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
