{ config, pkgs, lib, ... }:

{
  hardware.raspberry-pi."4".fkms-3d.enable = true;
  hardware.raspberry-pi."4".dwc2.enable = true;
  boot.loader.raspberryPi.firmwareConfig = "dtparams=sd_poll_once=on";

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;
  networking.hostName = "raspi4-nixos-jonge";
  networking.wireless.enable = true;
  networking.wireless.networks."Trafo Hub Member".psk = "@PASS_TRAFO@";
  networking.firewall.logRefusedConnections = false;
  networking.wireless.environmentFile = "/var/secrets/wireless.env";
  networking.wireless.userControlled.enable = true;

  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [ git vim ];

  system.stateVersion = "22.05"; # Did you read the comment?
}
