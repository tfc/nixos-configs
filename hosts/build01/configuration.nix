{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.initrd.systemd.enable = true;
  boot.cleanTmpDir = true;

  networking.hostName = "build01";
  networking.interfaces.ens18.ipv4.addresses = [{
    address = "88.198.83.206";
    prefixLength = 24;
  }];
  networking.defaultGateway = "88.198.83.193";
  networking.nameservers = [ "8.8.8.8" ];
  networking.firewall.logRefusedConnections = false;

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  services.openssh.enable = true;

  # we're a VM here, so no KVM and nixos tests
  nix.settings.system-features = [ "benchmark" "big-parallel" ];

  system.stateVersion = "22.11";
}