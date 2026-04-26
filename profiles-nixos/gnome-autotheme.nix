{ pkgs, lib, ... }:
let
  sensorPath = "/sys/bus/iio/devices/iio:device0/in_illuminance_raw";

  theme-switcher = pkgs.writeShellApplication {
    name = "theme-switcher";

    runtimeInputs = [
      pkgs.glib
      pkgs.coreutils
    ];

    text = ''
      threshold=800
      interval=20
      current=""

      while :; do
        raw=$(cat "${sensorPath}" 2>/dev/null || true)
        if [[ "$raw" =~ ^[0-9]+$ ]]; then
          if [ "$raw" -lt "$threshold" ]; then
            desired="prefer-dark"
          else
            desired="prefer-light"
          fi
          if [ "$desired" != "$current" ] \
              && gsettings set org.gnome.desktop.interface color-scheme "$desired"; then
            current="$desired"
          fi
        fi
        sleep "$interval"
      done
    '';
  };
in

{
  environment.systemPackages = [
    theme-switcher
  ];

  # The iio-sensor-proxy frequently gets stuck reporting 0 lux after resume;
  # bouncing the service is the known fix.
  systemd.services.iio-sensor-proxy-resume-fix = {
    description = "Restart iio-sensor-proxy after resume";
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart iio-sensor-proxy.service";
    };
  };

  systemd.user.services.theme-switcher = {
    description = "Set GNOME theme based on ambient brightness";
    unitConfig = {
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=GNOME";
      ConditionPathExists = sensorPath;
    };
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.getExe theme-switcher;
      Restart = "on-failure";
      RestartSec = 5;

      # Sandboxing: only needs to read the iio sensor file and talk to the
      # session dconf-service over the user D-Bus.
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      PrivateTmp = true;
      PrivateNetwork = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = [ "AF_UNIX" ];
      IPAddressDeny = "any";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
      ];
      CapabilityBoundingSet = "";
      UMask = "0077";
    };
  };
}
