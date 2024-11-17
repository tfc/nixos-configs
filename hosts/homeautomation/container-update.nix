{ pkgs, lib, ... }:

let

  update-containers = pkgs.writeShellScriptBin "update-containers" ''
    images=$(${pkgs.podman}/bin/podman ps -a --format="{{.Image}}" | sort -u)

    for image in $images; do
      ${pkgs.podman}/bin/podman pull "$image"
    done
  '';

  systemd-timer = { name, OnCalendar, ExecStart }: {
    systemd.timers.${name} = {
      timerConfig = {
        Unit = "${name}.service";
        inherit OnCalendar;
      };
      wantedBy = [ "timers.target" ];
    };

    systemd.services.${name} = {
      serviceConfig = {
        Type = "oneshot";
        inherit ExecStart;
      };
    };
  };
in

lib.mkMerge [
  (systemd-timer {
    name = "update-containers";
    OnCalendar = "Mon 02:00";
    ExecStart = "${update-containers}/bin/update-containers";
  })
  (systemd-timer {
    name = "restart-ha";
    OnCalendar = "Tue 02:00";
    ExecStart = "${pkgs.systemd}/bin/systemctl try-restart podman-homeassistant.service";
  })
  (systemd-timer {
    name = "prune-containers";
    OnCalendar = "Tue 04:00";
    ExecStart = "${pkgs.podman}/bin/podman system prune --all -f";
  })
]
