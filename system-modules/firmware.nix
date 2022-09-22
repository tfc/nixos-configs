{ pkgs, ... }:

{
  hardware.cpu.intel.updateMicrocode = pkgs.stdenv.isx86_64;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true; # needed by the unfree firmware blobs
  services.fwupd.enable = true;
}
