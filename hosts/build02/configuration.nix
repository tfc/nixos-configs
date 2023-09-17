{ config, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./matomo.nix
  ];
  boot.loader.systemd-boot.enable = true;
  boot.tmp.cleanOnBoot = true;
  boot.loader.systemd-boot.configurationLimit = 2;

  disko.devices = import ./single-gpt-disk-fullsize-ext4.nix "/dev/sda";

  networking.hostName = "build02";
  networking.domain = "nix-consulting.de";
  networking.firewall.logRefusedConnections = false;

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  services.openssh.enable = true;
  services.fail2ban.enable = true;

  # we're a VM here, so no KVM and nixos tests
  nix.settings.system-features = [ "benchmark" "big-parallel" ];

  system.stateVersion = "23.05";
}
