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
    flakeInputs.argunix.nixosModules.argunix-builder
    ./ai.nix
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  nixpkgs.overlays = [
    self.overlays.default
    flakeInputs.argunix.overlays.default
    flakeInputs.llm-agents.overlays.default
  ];

  services.displayManager.gdm.autoSuspend = false;

  services.argunix-builder = {
    enable = false;
    argunixHost = "argunix.nix-consulting.net";
    argunixPort = 45678;
    enrollmentTokenFile = "/tmp/argunix-token";
  };

  services.tailscale.enable = true;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;
  };
  networking.hostName = "work";
  networking.networkmanager.enable = true;
  boot.initrd.systemd.enable = true;

  boot.extraModprobeConfig = ''
    options kvm_amd nested=1
  '';

  powerManagement.cpuFreqGovernor = "balanced";

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
