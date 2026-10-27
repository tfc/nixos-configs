{ pkgs, ... }:

{
  networking.wireless = {
    extraConfig = "country=DE";
    networks.jongenet.authProtocols = [ "WPA-PSK" ];
  };

  boot.extraModprobeConfig = ''
    options brcmfmac roamoff=1
  '';

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan0", RUN+="${pkgs.iw}/bin/iw dev wlan0 set power_save off"
  '';
}
