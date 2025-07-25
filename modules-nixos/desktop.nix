{ pkgs, ... }:

{
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs.gnomeExtensions; [
    appindicator
    autohide-battery
    bluetooth-quick-connect
    blur-my-shell
    sound-output-device-chooser
    spotify-tray
    useless-gaps
    pkgs.wireguard-tools # for vpn stuff
  ];

  services.displayManager.gdm = {
    enable = true;
    wayland = false;
  };

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.options = "eurosign:e";
    wacom.enable = true;
  };
  services.libinput.enable = true;

  fonts.packages = [
    pkgs.google-fonts
  ];
}
