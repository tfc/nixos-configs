{ config, lib, pkgs, ... }:
let
  cfg = config.customization;

  logo = pkgs.runCommand "logo.png" { HOME = "/build"; } ''
    ${pkgs.inkscape}/bin/inkscape \
      -w 256 \
      -o "$out" \
      ${cfg.plymouth-logo.logoPath}
  '';
  customBreeze = pkgs.kdePackages.breeze-plymouth.override {
    logoFile = logo;
    logoName = "logo";
    osName = "NixOS";
    osVersion = "2026";
  };
in
{
  options.customization = {
    gdm-logo = {
      enable = lib.mkEnableOption "GDM icon customization" // { default = true; };
      logoPath = lib.mkOption {
        type = lib.types.path;
        default = ./artwork/applicative-white.svg;
        description = "Path to the logo file";
      };
    };
    gnome-background = {
      enable = lib.mkEnableOption "GNOME custom background setter" // { default = true; };
      backgroundFile = lib.mkOption {
        type = lib.types.path;
        default = ./artwork/wallpaper-applicative.png;
        description = "Path to the background file";
      };
    };
    plymouth-logo = {
      enable = lib.mkEnableOption "Plymouth icon customization" // { default = true; };
      logoPath = lib.mkOption {
        type = lib.types.path;
        default = ./artwork/applicative-white.svg;
        description = "Path to the logo file (SVG)";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.gdm-logo.enable {
      programs.dconf.profiles.gdm.databases = [
        {
          settings."org/gnome/login-screen" = {
            logo = builtins.toString cfg.gdm-logo.logoPath;
          };
        }
      ];
    })
    (lib.mkIf cfg.gnome-background.enable {
      services.desktopManager.gnome.extraGSettingsOverrides = ''
        [org.gnome.desktop.background]
        picture-uri='file://${cfg.gnome-background.backgroundFile}'
      '';
    })
    (lib.mkIf cfg.plymouth-logo.enable {
      boot.plymouth = {
        inherit logo;
        themePackages = [ customBreeze ];
      };
    })
  ];
}
