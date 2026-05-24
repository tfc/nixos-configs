{
  pkgs,
  lib,
  self,
  flakeInputs,
  ...
}:

{
  imports = [
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
    self.nixosProfiles.obsbot
    flakeInputs.home-manager.nixosModules.home-manager
    ./ai.nix
    ./hardware-configuration.nix
    ./nvidia.nix
    #self.nixosProfiles.argunix
  ];

  nixpkgs.overlays = [
    self.overlays.default
    flakeInputs.llm-agents.overlays.default
  ];

  services.displayManager.gdm.autoSuspend = false;

  services.tailscale.enable = true;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;
  };
  networking.hostName = "work";
  networking.networkmanager.enable = true;
  boot.initrd.systemd.enable = true;

  # amd-pstate-epp (the active driver on this CPU) only accepts "performance"
  # and "powersave". "balanced" was silently rejected; the system fell back to
  # the kernel default ("powersave"). For a sustained AI/video workstation,
  # pin to performance — the GPU is mostly idle anyway, but CPU bursts during
  # encodes / model loads benefit from immediate boost.
  powerManagement.cpuFreqGovernor = "performance";

  # Compressed RAM swap takes priority over the on-disk swap partition. With
  # 32 GB RAM and heavy Resolve/Ollama peaks, this keeps the working set off
  # the NVMe and avoids the latency cliff of paging to disk.
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;
  boot.kernel.sysctl."vm.swappiness" = 10;

  # Hardware-accelerated video decode for Firefox / mpv on NVIDIA via the
  # libva → NVDEC shim shipped in nvidia_drv_video.so.
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.options = "eurosign:e,caps:escape";
  };
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.tfc = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  programs.dconf.profiles.gdm.databases = [
    {
      settings."org/gnome/desktop/interface".scaling-factor = lib.gvariant.mkUint32 2;
    }
  ];

  security.run0.wheelNeedsPassword = false;
  security.run0.enableSudoAlias = true;
  security.sudo.enable = false;

  services.fwupd.enable = true;
  services.openssh.enable = true;

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
        gnome
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

}
