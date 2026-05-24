{ ... }:

{
  # PowerTOP's auto-tune defaults applied at boot: USB/SATA/PCIe runtime PM,
  # audio codec power save, etc. Typically 1-3 W saved on a Framework 13.
  powerManagement.powertop.enable = true;

  # Let NetworkManager put the Wi-Fi radio into power-save when associated.
  networking.networkmanager.wifi.powersave = true;

  # Compressed RAM swap takes priority over the on-disk swapfile, reducing
  # NVMe writes under memory pressure and softening the latency cliff when
  # the working set briefly spikes over physical RAM.
  zramSwap.enable = true;
  zramSwap.memoryPercent = 25;

  # With swap on NVMe (and zram in front of it), bias the kernel toward
  # keeping pages resident.
  boot.kernel.sysctl."vm.swappiness" = 10;

  # Cap battery charge at 80% for cell longevity. The Framework EC exposes
  # the threshold via /sys; cros_ec (enabled by hardware.framework.enableKmod)
  # makes the file writable. The udev rule reapplies the value on every
  # battery add/change event, so it survives suspend/resume and EC resets.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="power_supply", KERNEL=="BAT?", ATTR{charge_control_end_threshold}!="", ATTR{charge_control_end_threshold}="80"
  '';
}
