{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.customization;
  gnomeEnabled = config.services.desktopManager.gnome.enable;
  plasmaEnabled = config.services.desktopManager.plasma6.enable;

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

  # Render the tiling wallpaper SVG to a 4K PNG, recoloring its .bg (background)
  # and .logo (logo) fills to the requested HTML color codes. Both placeholder
  # fills appear exactly once in the SVG's <style> block, so the substitution is
  # unambiguous.
  mkWallpaper =
    name:
    { backgroundColor, logoColor }:
    pkgs.runCommand name
      {
        HOME = "/build";
        nativeBuildInputs = [ pkgs.inkscape ];
      }
      ''
        cp ${cfg.background.tilingSvg} colored.svg
        # Anchor each substitution on its class selector. Replacing the bare
        # 'fill:#000000' would also hit a background recolored to #000000 (the
        # dark scheme), collapsing background and logo to the same grey.
        substituteInPlace colored.svg \
          --replace-fail '.bg   { fill:#ffffff }' '.bg   { fill:${backgroundColor} }' \
          --replace-fail '.logo { fill:#000000 }' '.logo { fill:${logoColor} }'
        inkscape -w 3840 -h 2160 -o "$out" colored.svg
      '';

  lightWallpaper = mkWallpaper "wallpaper-applicative-light.png" {
    inherit (cfg.background.light) backgroundColor logoColor;
  };
  darkWallpaper = mkWallpaper "wallpaper-applicative-dark.png" {
    inherit (cfg.background.dark) backgroundColor logoColor;
  };

  # Plasma wallpaper KPackage with light (images/) and dark (images_dark/)
  # variants. Plasma switches between them following the color scheme.
  plasmaWallpaperName = "Applicative";
  plasmaWallpaper = pkgs.runCommand "plasma-wallpaper-applicative" { } ''
    dir=$out/share/wallpapers/${plasmaWallpaperName}
    mkdir -p $dir/contents/images $dir/contents/images_dark
    ln -s ${lightWallpaper} $dir/contents/images/3840x2160.png
    ln -s ${darkWallpaper} $dir/contents/images_dark/3840x2160.png
    cat > $dir/metadata.json <<'JSON'
    {
      "KPlugin": {
        "Id": "${plasmaWallpaperName}",
        "Name": "Applicative Systems",
        "Authors": [ { "Name": "Applicative Systems" } ],
        "License": "proprietary"
      }
    }
    JSON
  '';
  plasmaWallpaperPath = "${plasmaWallpaper}/share/wallpapers/${plasmaWallpaperName}";

  apply-plasma-wallpaper = pkgs.writeShellApplication {
    name = "plasma-apply-applicative-wallpaper";
    runtimeInputs = [ pkgs.kdePackages.plasma-workspace ];
    text = ''
      plasma-apply-wallpaperimage ${plasmaWallpaperPath}
    '';
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
      enable = lib.mkEnableOption "GDM icon customization" // {
        default = true;
      };
      logoPath = lib.mkOption {
        type = lib.types.path;
        default = ./artwork/applicative-white.svg;
        description = "Path to the logo file";
      };
    };
    background = {
      enable =
        lib.mkEnableOption (
          "the Applicative Systems light/dark wallpaper. Applied to whichever of "
          + "GNOME and Plasma 6 are enabled on the host"
        )
        // {
          default = true;
        };
      tilingSvg = lib.mkOption {
        type = lib.types.path;
        default = ./artwork/logos/tiling-wallpaper.svg;
        description = ''
          Path to the tiling wallpaper SVG. Its <style> block must expose a
          .bg fill of #ffffff and a .logo fill of #000000, which get recolored
          to the light/dark color codes below when rendering the PNGs.
        '';
      };
      light = {
        backgroundColor = lib.mkOption {
          type = lib.types.str;
          default = "#f0f0f0";
          description = "HTML color code for the wallpaper background in the light color scheme";
        };
        logoColor = lib.mkOption {
          type = lib.types.str;
          default = "#999999";
          description = "HTML color code for the tiled logos in the light color scheme";
        };
      };
      dark = {
        backgroundColor = lib.mkOption {
          type = lib.types.str;
          default = "#000000";
          description = "HTML color code for the wallpaper background in the dark color scheme";
        };
        logoColor = lib.mkOption {
          type = lib.types.str;
          default = "#737373";
          description = "HTML color code for the tiled logos in the dark color scheme";
        };
      };
      enforceAtLogin =
        lib.mkEnableOption (
          "re-applying the wallpaper at every session start, overriding per-user choices "
          + "(GNOME: reset the user's background keys to the system default; "
          + "Plasma: apply the wallpaper package to all desktops)"
        )
        // {
          default = true;
        };
    };
    plymouth-logo = {
      enable = lib.mkEnableOption "Plymouth icon customization" // {
        default = true;
      };
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
            logo = toString cfg.gdm-logo.logoPath;
          };
        }
      ];
    })
    # GNOME: system gsettings defaults for light and dark color schemes.
    (lib.mkIf (cfg.background.enable && gnomeEnabled) {
      services.desktopManager.gnome.extraGSettingsOverrides = ''
        [org.gnome.desktop.background]
        picture-uri='file://${lightWallpaper}'
        picture-uri-dark='file://${darkWallpaper}'
      '';
    })
    (lib.mkIf (cfg.background.enable && cfg.background.enforceAtLogin && gnomeEnabled) {
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
    # Plasma: wallpaper KPackage with light/dark variants.
    (lib.mkIf (cfg.background.enable && plasmaEnabled) {
      environment.systemPackages = [ plasmaWallpaper ];
      # The lock screen reads its wallpaper from kscreenlockerrc, which KConfig
      # cascades from /etc/xdg; users who never changed it get ours.
      environment.etc."xdg/kscreenlockerrc".text = lib.mkAfter ''

        [Greeter][Wallpaper][org.kde.image][General]
        Image=${plasmaWallpaperPath}
      '';
    })
    (lib.mkIf (cfg.background.enable && cfg.background.enforceAtLogin && plasmaEnabled) {
      systemd.user.services.plasma-apply-applicative-wallpaper = {
        description = "Apply Applicative Systems wallpaper to all Plasma desktops";
        unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=KDE";
        wantedBy = [ "plasma-workspace.target" ];
        after = [ "plasma-plasmashell.service" ];
        requires = [ "plasma-plasmashell.service" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe apply-plasma-wallpaper;
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
