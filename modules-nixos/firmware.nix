{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable Intel microcode updates only on x86 hosts where the AMD microcode
  # option hasn't already been set by some host-specific module (e.g.
  # nixos-hardware's AMD CPU module). The hostPlatform guard keeps
  # microcode-intel out of the closure on aarch64 builds.
  hardware.cpu.intel.updateMicrocode = lib.mkDefault (
    pkgs.stdenv.hostPlatform.isx86_64 && !config.hardware.cpu.amd.updateMicrocode
  );
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true; # needed by the unfree firmware blobs
  services.fwupd.enable = true;
}
