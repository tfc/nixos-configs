# zram swap with the old NVMe swap partition as writeback device.
# Sysctls adapted from Connor Baker's config: https://github.com/ConnorBaker/nixos-configs
{ config, utils, ... }:

let
  # By PARTUUID because the swap signature's UUID no longer means anything.
  writebackDevice = "/dev/disk/by-partuuid/2695a3a3-b519-4b64-a9c9-c86f0e762cd4";
  writebackDeviceUnit = "${utils.escapeSystemdPath writebackDevice}.device";
in
{
  boot.kernel.sysctl = {
    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    # Reclaim earlier and in bigger batches so we compress ahead of demand
    # instead of stalling allocators once memory is already tight.
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    # Swapping to RAM has no seek cost, so reading whole 8-page clusters
    # around a fault only wastes decompression work. 0 = read one page.
    "vm.page-cluster" = 0;

    # https://github.com/pop-os/default-settings/blob/master_noble/etc/sysctl.d/10-pop-default-settings.conf
    # Anon pages go to zram (cheap) while file pages would have to be re-read
    # from disk, so bias reclaim hard towards anon. Only sane *because* zram
    # is the only swap device.
    "vm.swappiness" = 190;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # Percent of RAM as *uncompressed* device size. Measured zstd ratio here
    # is ~4-5:1, so a full 200% device costs well under half of RAM.
    memoryPercent = 200;
    # Not a second swap device: as one, it would only receive pages evicted
    # after zram is full, i.e. warmer ones than zram holds. As writeback
    # device, zram-writeback below moves the *coldest* pages there.
    inherit writebackDevice;
  };

  # systemd-gpt-auto-generator would swapon the partition by its GPT type
  # ("Linux swap") and keep it busy before zram can claim it. / and /boot are
  # in fstab, so nothing else here relies on GPT auto-discovery.
  boot.kernelParams = [ "systemd.gpt_auto=0" ];

  # zram-generator orders setup against nothing but the swap unit, so it can
  # race udev creating the /dev/disk/by-* link and fail to set backing_dev.
  # Any NixOS service definition emits its own Environment=PATH, and this
  # instance drop-in overrides the template's, so repeat the template's path
  # (util-linux) or systemd-makefs can't find mkswap.
  systemd.services."systemd-zram-setup@zram0" = {
    overrideStrategy = "asDropin";
    inherit (config.systemd.services."systemd-zram-setup@") path;
    requires = [ writebackDeviceUnit ];
    after = [ writebackDeviceUnit ];
  };

  # zram never moves pages to its backing device on its own, only when told
  # via sysfs. Each run writes out what the previous run marked idle
  # (= untouched for at least one interval), then re-marks everything.
  # https://docs.kernel.org/admin-guide/blockdev/zram.html#writeback
  systemd.services.zram-writeback = {
    description = "Write idle zram pages to the backing device";
    after = [ "systemd-zram-setup@zram0.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      z=/sys/block/zram0
      # EIO/ENOSPC when nothing qualifies or the backing device is full.
      echo idle > $z/writeback || true
      echo all > $z/idle
    '';
  };
  systemd.timers.zram-writeback = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1h";
      OnUnitActiveSec = "1h";
    };
  };
}
