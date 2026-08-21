{ ... }:

{
  # PowerTOP's auto-tune defaults applied at boot: USB/SATA/PCIe runtime PM,
  # audio codec power save, etc. Typically 1-3 W saved on a Framework 13.
  powerManagement.powertop.enable = true;

  # Wi-Fi power saving moved to wifi.nix, where it is now disabled.

  # zram itself comes from nixosProfiles.zram; a laptop deviates from its
  # desktop defaults in both directions: a small device because the 8 GB
  # swapfile behind it is the real overflow tier, and low swappiness because
  # compressing pages costs CPU (= battery) and we would rather keep the
  # working set resident than churn it.
  zramSwap.memoryPercent = 25;
  boot.kernel.sysctl."vm.swappiness" = 10;

  # Cap battery charge at 80% for cell longevity. The Framework EC exposes
  # the threshold via /sys; cros_ec (enabled by hardware.framework.enableKmod)
  # makes the file writable. The udev rule reapplies the value on every
  # battery add/change event, so it survives suspend/resume and EC resets.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="power_supply", KERNEL=="BAT?", ATTR{charge_control_end_threshold}!="", ATTR{charge_control_end_threshold}="80"
  '';
}
