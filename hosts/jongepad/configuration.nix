{ pkgs, lib, config, ... }: {

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.crypted = {
    allowDiscards = true;
    device = "/dev/nvme0n1p2";
    preLVM = true;
  };
  boot.initrd.systemd.enable = true;
  boot.tmp.cleanOnBoot = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # The internet says that this helps against recurring black screen periods
  # with external screens where dmesg says
  # "i915 0000:00:02.0: [drm] *ERROR* CPU pipe B FIFO underrun"
  # https://bbs.archlinux.org/viewtopic.php?id=263720
  boot.kernelParams = [ "intel_idle.max_cstate=4" ];

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [ git vim wget ];
  environment.variables = {
    EDITOR = lib.mkOverride 0 "vim";
    TERM = "xterm-256color";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "jongepad";
  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs.bash.enableCompletion = true;

  services.avahi.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "22.05";

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE tfc WITH LOGIN PASSWORD 'tfc' CREATEDB;
      CREATE DATABASE tfc;
      GRANT ALL PRIVILEGES ON DATABASE tfc TO tfc;
    '';
  };

  powerManagement.powertop.enable = true;
}
