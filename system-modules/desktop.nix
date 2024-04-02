{ pkgs, ... }:

let
  gnome = { pkgs, lib, ... }: {
    environment.gnome.excludePackages = [ pkgs.gnome3.geary ];
    services.xserver.desktopManager.gnome.enable = true;
    environment.systemPackages = with pkgs.gnomeExtensions; [
      appindicator
      autohide-battery
      bluetooth-quick-connect
      blur-my-shell
      sound-output-device-chooser
      spotify-tray
      useless-gaps
    ] ++ (with pkgs; [
      gnome-network-displays
    ]);
    services.gnome.evolution-data-server = {
      enable = true;
      plugins = [ pkgs.evolution-ews ];
    };
    programs.evolution = {
      enable = true;
      plugins = [ pkgs.evolution-ews ];
    };
  };

  steam = { pkgs, config, ... }: {
    hardware.opengl = {
      # this fixes the "glXChooseVisual failed" bug,
      # context: https://github.com/NixOS/nixpkgs/issues/47932
      enable = true;
      driSupport32Bit = true;
    };
    hardware.opengl.extraPackages = [ pkgs.mesa.drivers ];

    # optionally enable 32bit pulseaudio support if pulseaudio is enabled
    hardware.pulseaudio.support32Bit = config.hardware.pulseaudio.enable;

    hardware.steam-hardware.enable = true;

    programs.steam.enable = true;
  };

  screen-sharing-in-browser-wayland = { ... }: {
    services.pipewire.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

in
{
  imports = [
    gnome
    steam
    #screen-sharing-in-browser-wayland
  ];

  security.rtkit.enable = true;

  services.xserver = {
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    enable = true;
    libinput.enable = true;
    xkb.layout = "us";
    xkb.options = "eurosign:e";
    wacom.enable = true;
  };

  environment.systemPackages = with pkgs; [
    thunderbird-bin
    wireguard-tools
  ];

  services.localtimed.enable = true;
}
