_:

{
  system.autoUpgrade = {
    enable = true;
    flake = "github:tfc/nixos-configs";
    flags = [ " --no-write-lock-file" ];
    allowReboot = true;
    dates = "02:00";
    rebootWindow = {
      lower = "02:00";
      upper = "05:00";
    };
  };
}
