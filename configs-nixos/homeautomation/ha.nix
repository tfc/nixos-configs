{ pkgs, lib, ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:stable";
      extraOptions = [
        "--network=host"
        "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
        "--device=/dev/ttyACM0:/dev/ttyACM0"
      ];
    };
  };

  virtualisation.podman = {
    enable = true;
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
    };
  };

  systemd.simple-timers = {
    update-containers = {
      OnCalendar = "Mon 02:00";
      ExecStart = lib.getExe (pkgs.writeShellScriptBin "update-containers" ''
        images=$(${pkgs.podman}/bin/podman ps -a --format="{{.Image}}" | sort -u)

        for image in $images; do
          ${pkgs.podman}/bin/podman pull "$image"
        done
      '');
    };
    restart-ha = {
      OnCalendar = "Tue 02:00";
      ExecStart = "${pkgs.systemd}/bin/systemctl try-restart podman-homeassistant.service";
    };
  };
}
