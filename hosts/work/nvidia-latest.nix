{ pkgs, lib, config, ... }:

{
  nixpkgs.overlays = [
    (_: prev: {
      myKernelPackages = prev.zfs.latestCompatibleLinuxPackages.extend (_: kernelSuper: {
        nvidiaPackages = kernelSuper.nvidiaPackages // {
          nvidia_testing = kernelSuper.nvidiaPackages.mkDriver {
            version = "560.35.03";
            sha256_32bit = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
            sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
            settingsSha256 = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
            sha256_aarch64 = lib.fakeHash;
            openSha256 = lib.fakeHash;
            persistencedSha256 = lib.fakeHash;
          };
        };
      });
    })
  ];

  boot.kernelPackages = pkgs.myKernelPackages;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.nvidia_testing;
  };

  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware.graphics.enable = true;
}
