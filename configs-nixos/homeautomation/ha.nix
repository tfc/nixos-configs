{ pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:stable";
      pull = "newer";
      networks = [ "host" ];
      capabilities = {
        NET_RAW = true;
        NET_BIND_SERVICE = true;
      };
      devices = [ "/dev/ttyACM0:/dev/ttyACM0" ];
    };
  };

  virtualisation.podman = {
    enable = true;
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
    };
  };

  systemd.simple-timers.restart-ha = {
    OnCalendar = "Tue 02:00";
    ExecStart = "${pkgs.systemd}/bin/systemctl try-restart podman-homeassistant.service";
  };
}
