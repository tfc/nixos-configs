{ pkgs, config, ... }:

{
  hardware.graphics.enable = true;
  hardware.amdgpu.zluda.enable = true;

  programs.nix-required-mounts = {
    enable = true;
    presets.zluda.enable = true;
  };
}
