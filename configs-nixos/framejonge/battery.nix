{ ... }:

{
  # PowerTOP's auto-tune defaults applied at boot: USB/SATA/PCIe runtime PM,
  # audio codec power save, etc. Typically 1-3 W saved on a Framework 13.
  powerManagement.powertop.enable = true;

  # Wi-Fi power saving moved to wifi.nix, where it is now disabled.

  boot.zswap.enable = true;

  # Cap battery charge at 80% for cell longevity. The Framework EC exposes
  # the threshold via /sys; cros_ec (enabled by hardware.framework.enableKmod)
  # makes the file writable. The udev rule reapplies the value on every
  # battery add/change event, so it survives suspend/resume and EC resets.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="power_supply", KERNEL=="BAT?", ATTR{charge_control_end_threshold}!="", ATTR{charge_control_end_threshold}="80"
  '';
}
