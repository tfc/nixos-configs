{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  hardware.enableRedistributableFirmware = true;

  boot.initrd.secrets."/crypto_keyfile.bin" = null;
  boot.initrd.systemd.enable = true;

  # Enable swap on luks
  boot.initrd.luks.devices."luks-f21e1409-9581-4bd1-b0cb-649421782af9".device = "/dev/disk/by-uuid/f21e1409-9581-4bd1-b0cb-649421782af9";
  boot.initrd.luks.devices."luks-f21e1409-9581-4bd1-b0cb-649421782af9".keyFile = "/crypto_keyfile.bin";

  boot.cleanTmpDir = true;

  networking.hostName = "jongebook";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.utf8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.utf8";
    LC_IDENTIFICATION = "de_DE.utf8";
    LC_MEASUREMENT = "de_DE.utf8";
    LC_MONETARY = "de_DE.utf8";
    LC_NAME = "de_DE.utf8";
    LC_NUMERIC = "de_DE.utf8";
    LC_PAPER = "de_DE.utf8";
    LC_TELEPHONE = "de_DE.utf8";
    LC_TIME = "de_DE.utf8";
  };

  environment.variables = {
    EDITOR = lib.mkOverride 0 "vim";
    TERM = "xterm-256color";
  };

  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  sound.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  system.stateVersion = "22.05";

  services.postgresql.enable = true;
  services.postgresql.initialScript = pkgs.writeText "postgres-init" ''
    CREATE ROLE tfc WITH CREATEDB LOGIN;
    CREATE DATABASE tfc WITH OWNER tfc;
  '';
  services.postgresql.enableTCPIP = true;
}
