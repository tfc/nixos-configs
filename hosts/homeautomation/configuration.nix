{ config, pkgs, lib, ... }:

{
  imports = [
    ./ha.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
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

  users = {
    users.tfc = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";
}
