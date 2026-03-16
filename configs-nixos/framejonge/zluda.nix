{ pkgs, config, ... }:

{
  hardware.graphics.enable = true;
  hardware.amdgpu.opencl.enable = true;
  hardware.graphics.extraPackages = [ pkgs.zluda ];

  programs.nix-required-mounts = {
    enable = true;
    presets.nvidia-gpu.enable = true;
    # Workaround for <https://github.com/NixOS/nix/issues/9272>, copied from
    # <https://github.com/nix-community/infra/pull/1807>.
    extraWrapperArgs = [
      "--run shift"
      "--add-flag '${
        builtins.unsafeDiscardOutputDependency
          (derivation {
            name = "needs-cuda";
            builder = "_";
            system = "_";
            requiredSystemFeatures = [ "cuda" ];
          }).drvPath
      }'"
    ];
  };
}
