{ pkgs, ... }:

let
  gnome = { pkgs, lib, ... }: {
    environment.gnome.excludePackages = [ pkgs.gnome3.geary ];
    services.xserver.desktopManager.gnome.enable = true;
    environment.systemPackages = with pkgs.gnomeExtensions; [
      appindicator
      autohide-battery
      blur-my-shell
      just-perfection
      net-speed-simplified
      sound-output-device-chooser
      spotify-tray
      thanatophobia
      time-awareness
      transparent-top-bar-adjustable-transparency
      tweaks-in-system-menu
      unblank
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
    layout = "us";
    libinput.enable = true;
    xkbOptions = "eurosign:e";
    wacom.enable = true;
  };

  environment.systemPackages = with pkgs; [
    thunderbird-bin
  ];

  services.localtime.enable = true;
}
