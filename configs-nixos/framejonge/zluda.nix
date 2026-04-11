{ pkgs, config, ... }:

{
  hardware.graphics.enable = true;
  hardware.amdgpu.zluda.enable = true;

  programs.nix-required-mounts = {
    enable = true;
    presets.zluda.enable = true;
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
  };

  services.nextjs-ollama-llm-ui.enable = true;

}
