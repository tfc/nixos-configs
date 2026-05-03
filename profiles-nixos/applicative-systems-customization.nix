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

  reset-background = pkgs.writeShellApplication {
    name = "gnome-reset-background";
    runtimeInputs = [ pkgs.glib ];
    text = ''
      gsettings reset org.gnome.desktop.background picture-uri
      gsettings reset org.gnome.desktop.background picture-uri-dark
    '';
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
      lightFile = lib.mkOption {
        type = lib.types.path;
        default = ./artwork/wallpaper-applicative-light.webp;
        description = "Path to the wallpaper used with the light color scheme";
      };
      darkFile = lib.mkOption {
        type = lib.types.path;
        default = ./artwork/wallpaper-applicative-dark.webp;
        description = "Path to the wallpaper used with the dark color scheme";
      };
      resetUserBackground = lib.mkEnableOption (
        "resetting each user's GNOME background keys to the system default at session start, "
        + "so per-user dconf overrides do not shadow the system-provided wallpaper"
      ) // { default = true; };
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
        picture-uri='file://${cfg.gnome-background.lightFile}'
        picture-uri-dark='file://${cfg.gnome-background.darkFile}'
      '';
    })
    (lib.mkIf (cfg.gnome-background.enable && cfg.gnome-background.resetUserBackground) {
      systemd.user.services.gnome-reset-background = {
        description = "Reset GNOME background to system default at login";
        unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=GNOME";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe reset-background;
        };
      };
    })
    (lib.mkIf cfg.plymouth-logo.enable {
      boot.plymouth = {
        inherit logo;
        themePackages = [ customBreeze ];
      };
    })
  ];
}
