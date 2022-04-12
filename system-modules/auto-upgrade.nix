{ ... }:

{
  system.autoUpgrade = {
    enable = true;
    flake = "github:tfc/nixos-configs";
    allowReboot = true;
    flags = [ " --no-write-lock-file" ];
  };
}
