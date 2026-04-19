{ pkgs, lib, ... }:
let
  update-theme-brightness = pkgs.writeShellApplication {
    name = "update-theme-brightness";

    runtimeInputs = [
      pkgs.glib
    ];

    text = ''
      set -x
      BRIGHTNESS=$(cat '/sys/bus/iio/devices/iio:device0/in_illuminance_raw')
      if [ "$BRIGHTNESS" -lt 100 ]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
      else
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
      fi
      set +x
    '';
  };
in

{
  environment.systemPackages = [
    update-theme-brightness
  ];

  systemd.user.services.theme-switcher = {
    description = "Set GNOME theme based on brightness";
    unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=GNOME";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe update-theme-brightness}";
    };
  };

  systemd.user.timers.theme-switcher = {
    description = "Timer for theme-switcher";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "10s";
      Unit = "theme-switcher.service";
    };
  };
}
