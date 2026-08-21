{ pkgs, ... }:

{
  services.desktopManager.gnome.enable = true;

  environment.systemPackages =
    (with pkgs.gnomeExtensions; [
      appindicator
      autohide-battery
      bluetooth-quick-connect
      blur-my-shell
      useless-gaps
      pkgs.wireguard-tools # for vpn stuff
    ])
    ++ (with pkgs.gst_all_1; [
      gstreamer.out # default output is "bin"; the core plugins live in "out"
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ]);

  services.displayManager.gdm.enable = true;

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.options = "eurosign:e";
  };

  fonts.packages = [
    pkgs.google-fonts
  ];
}
