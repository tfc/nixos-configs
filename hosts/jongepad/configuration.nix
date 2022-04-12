{ pkgs, config, ... }: {

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.crypted = {
    allowDiscards = true;
    device = "/dev/nvme0n1p2";
    preLVM = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "intel_idle.max_cstate=4" ];
  boot.cleanTmpDir = true;

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [ git vim wget ];

  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "jongepad";
  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs.bash.enableCompletion = true;

  services.avahi.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "20.09";

  users.users.tfc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
  };
}
