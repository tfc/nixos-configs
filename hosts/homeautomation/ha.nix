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
}
