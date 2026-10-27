{
  config,
  pkgs,
  self,
  flakeInputs,
  ...
}:

{
  imports = [
    ./ai.nix
    ./hardware-configuration.nix
    ./nvidia.nix
    flakeInputs.home-manager.nixosModules.home-manager
    self.nixosModules.flakes
    self.nixosModules.nix-service
    self.nixosModules.nix-unstable
    self.nixosModules.remote-deployable
    self.nixosModules.simple-timers
    self.nixosModules.steam
    self.nixosModules.user-tfc
    self.nixosModules.virtualization
    self.nixosProfiles.applicative-systems-customization
    self.nixosProfiles.desktop-responsiveness
    self.nixosProfiles.traynix
    self.nixosProfiles.zram
  ];

  nixpkgs.overlays = [
    self.overlays.default
  ];

  services.tailscale.enable = true;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;
  };
  networking.hostName = "work";
  networking.networkmanager.enable = true;
  boot.tmp.cleanOnBoot = true;

  # Fan monitoring for the board's Super-I/O chip. The TUF B450-PLUS has an
  # ITE IT8665E, which the in-tree it87 driver does not recognise (its probe
  # fails with ENODEV), so pull in the out-of-tree patched driver. Two
  # wrinkles: it needs ignore_resource_conflict because the ACPI tables
  # reserve the Super-I/O port range, and it installs under the same module
  # name and directory as the in-tree driver, where depmod resolves the
  # collision in favour of the useless in-tree one — so move it to
  # updates/, which depmod searches first. Only fan1 (CPU) reports RPM.
  boot.extraModulePackages = [
    (config.boot.kernelPackages.it87.overrideAttrs (_: {
      postInstall = ''
        moddir=$out/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}
        mkdir -p $moddir/updates
        mv $moddir/kernel/drivers/hwmon/it87.ko $moddir/updates/it87.ko
      '';
    }))
  ];
  boot.kernelModules = [ "it87" ];
  boot.extraModprobeConfig = "options it87 ignore_resource_conflict=1";

  hardware.bluetooth.enable = true;
  hardware.facter.reportPath = ./facter.json;

  powerManagement.cpuFreqGovernor = "performance";

  # Plasma pulls in power-profiles-daemon, which takes ownership of the
  # cpufreq policy at session start and resets all cores to powersave /
  # EPP balance_performance — silently undoing the line above. This box is
  # a desktop workstation on mains power, so there is nothing for a profile
  # switcher to trade off; drop it and let cpufreq.service win.
  services.power-profiles-daemon.enable = false;

  # Hardware-accelerated video decode for Firefox / mpv on NVIDIA via the
  # libva → NVDEC shim shipped in nvidia_drv_video.so.
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";

    XKB_DEFAULT_LAYOUT = "us";
    XKB_DEFAULT_OPTIONS = "eurosign:e,caps:escape";
  };

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.options = "eurosign:e,caps:escape";
  };
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;

  # see wiki.nixos.org/wiki/KDE about locales
  i18n = {
    extraLocales = "all";
    imperativeLocale = true; # Unknown if needed (system settings sets user-level override?)
  };
  environment = {
    pathsToLink = [ "/share/i18n" ];
  };

  customization.gdm-logo.enable = false;
  customization.gnome-background.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.tfc = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    lm_sensors # `sensors` — read the it8665 fan channels enabled above
    transcribe-speakers
    transcribe-speakers-turns
    vim
    wget
    stdenv.cc.libc.out # kde locales
  ];

  security.run0.wheelNeedsPassword = false;
  security.run0.enableSudoAlias = true;
  security.run0.enable = true;
  security.sudo.enable = false;

  services.fwupd.enable = true;
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };

  # Intel wifi+bluetooth firmware ships in linux-firmware (redistributable,
  # cached). enableAllFirmware would additionally pull in build-requiring
  # unfree blobs we no longer need (broadcom-bt-firmware, b43, ...).
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.tfc = {
      home.stateVersion = "23.11";
      programs.home-manager.enable = true;
      imports = with self.homeManagerModules; [
        desktop
        kde
        obs
        programming
        programming-haskell
        shell-bash
        shelltools
        ssh
        tmux
        vim
        vscode
      ];
    };
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/93ae924f-d73d-4bb4-8c0b-589d63e5b6f8";
    fsType = "btrfs";
    options = [
      "defaults"
      "noatime" # no atime writes on a video archive
      "compress=zstd:3"
      "nofail" # don't block boot if the disk is missing
    ];
  };

  systemd.tmpfiles.rules = [
    "d /data 0755 tfc users - -"
    "d /data/video-cut   0755 tfc users - -"
    "h /data/video-cut   -    -   -     - +C"
  ];

  nix.settings = {
    substituters = [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
  };

}
