{ pkgs, config, lib, ... }:
let
  cfg = config.customization.gnome-background;
in
{
  options.customization.gnome-background = {
    enable = lib.mkEnableOption "GNOME custom background setter";
    backgroundFile = lib.mkOption {
      type = lib.types.path;
      default = ./artwork/wallpaper-color.png;
      description = "Path to the background file";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.gnome = {
      extraGSettingsOverrides = ''
        [org.gnome.desktop.background]
        picture-uri='file://${cfg.backgroundFile}'
      '';
    };
  };
}
