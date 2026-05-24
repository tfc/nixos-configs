{ pkgs, config, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true; # RTX 2080 SUPER is Turing (TU104); open modules support Turing+
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    # Keep the driver loaded between CUDA processes so repeated Ollama /
    # ffmpeg-NVENC invocations don't pay per-process driver init cost.
    nvidiaPersistenced = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  programs.nix-required-mounts = {
    enable = true;
    presets.nvidia-gpu.enable = true;
  };
}
