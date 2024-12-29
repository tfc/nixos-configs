{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    self.nixosModules.desktop
    self.nixosModules.firmware
    self.nixosModules.flakes
    self.nixosModules.make-linux-fast-again
    self.nixosModules.nix-unstable
    self.nixosModules.nixcademy-gdm-logo
    self.nixosModules.nixcademy-gnome-background
    self.nixosModules.nixcademy-plymouth-logo
    self.nixosModules.pipewire
    self.nixosModules.printing
    self.nixosModules.remote-deployable
    self.nixosModules.simple-timers
    self.nixosModules.steam
    self.nixosModules.user-tfc
    self.nixosModules.virtualization
    flakeInputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.permittedInsecurePackages = [ "electron-24.8.6" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.crypted = {
    allowDiscards = true;
    device = "/dev/nvme0n1p2";
    preLVM = true;
  };
  boot.initrd.systemd.enable = true;
  boot.tmp.cleanOnBoot = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # The internet says that this helps against recurring black screen periods
  # with external screens where dmesg says
  # "i915 0000:00:02.0: [drm] *ERROR* CPU pipe B FIFO underrun"
  # https://bbs.archlinux.org/viewtopic.php?id=263720
  boot.kernelParams = [ "intel_idle.max_cstate=4" ];

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

  networking.hostName = "jongepad";
  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  services.avahi.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "22.05";

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE tfc WITH LOGIN PASSWORD 'tfc' CREATEDB;
      CREATE DATABASE tfc;
      GRANT ALL PRIVILEGES ON DATABASE tfc TO tfc;
    '';
    settings = {
      shared_buffers = "2GB";
      work_mem = "256MB";
    };
  };

  powerManagement.powertop.enable = true;

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
