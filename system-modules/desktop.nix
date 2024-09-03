{ pkgs, ... }:

{
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs.gnomeExtensions; [
    appindicator
    autohide-battery
    bluetooth-quick-connect
    blur-my-shell
    sound-output-device-chooser
    spotify-tray
    useless-gaps
  ];

  services.xserver = {
    displayManager.gdm.enable = true;
    enable = true;
    xkb.layout = "us";
    xkb.options = "eurosign:e";
    wacom.enable = true;
  };
  services.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    wireguard-tools # for vpn stuff
  ];
}
