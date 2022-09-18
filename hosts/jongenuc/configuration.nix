{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.initrd.secrets."/crypto_keyfile.bin" = null;
  boot.initrd.luks.devices."luks-6326b359-7014-43fa-b0a5-552409feb656".device = "/dev/disk/by-uuid/6326b359-7014-43fa-b0a5-552409feb656";
  boot.initrd.luks.devices."luks-6326b359-7014-43fa-b0a5-552409feb656".keyFile = "/crypto_keyfile.bin";

  hardware.enableRedistributableFirmware = true;

  networking.hostName = "jongenuc";
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

  system.stateVersion = "22.05"; # Did you read the comment?
}
