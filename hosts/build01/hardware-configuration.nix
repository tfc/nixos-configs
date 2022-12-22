{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "sd_mod"
    "sr_mod"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5b749cd4-69fc-4120-b38e-fcc0920cd75b";
    fsType = "ext4";
  };

  swapDevices = [{
    device = "/dev/disk/by-uuid/500cfb47-c2b5-4081-b08e-b70080263964";
  }];

  networking.useDHCP = lib.mkDefault false;
  networking.interfaces.ens18.useDHCP = lib.mkDefault false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
