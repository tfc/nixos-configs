{ pkgs, ... }:

let
  intel = { pkgs, ... }: {
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl
        vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
      ];
      driSupport32Bit = true;
    };
  };
  gnome = { pkgs, lib, ... }: {
    environment.gnome.excludePackages = [ pkgs.gnome3.geary ];
    services.xserver.desktopManager.gnome.enable = true;
    environment.systemPackages = with pkgs.gnomeExtensions; [
      tilingnome
      sound-output-device-chooser
    ] ++ (with pkgs; [
      gnome-network-displays
    ]);
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
    intel
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

  environment.extraInit = ''
    xset s off -dpms
  '';

  environment.systemPackages = with pkgs; [
    firefox-bin
    thunderbird-bin
  ];
}
