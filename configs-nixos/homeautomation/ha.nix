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
        NET_ADMIN = true;
        NET_BIND_SERVICE = true;
        NET_RAW = true;
      };
      devices = [ "/dev/ttyACM0:/dev/ttyACM0" ];
    };
  };

  # No X-Forwarded-* headers on purpose: HA answers 400 to them unless its
  # reverse proxy settings (kept in HA's .storage, not YAML) are configured.
  services.nginx = {
    enable = true;
    virtualHosts.homeassistant = {
      default = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123";
        proxyWebsockets = true;
      };
    };
  };

  services.wyoming.piper.servers.de = {
    enable = true;
    voice = "de_DE-thorsten-medium";
    uri = "tcp://127.0.0.1:10200";
    # would advertise the LAN address, but we only listen on localhost
    zeroconf.enable = false;
  };

  nixpkgs.overlays = [
    (_: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (_: pyprev: {
          # Pulled in by piper-tts. The test matches an error message that
          # Python 3.14 words differently ("Expected str, got int").
          pyopenjtalk-plus = pyprev.pyopenjtalk-plus.overridePythonAttrs (old: {
            disabledTests = (old.disabledTests or [ ]) ++ [
              "test_run_njd_from_mecab_invalid_input_should_not_break_next_call"
            ];
          });
        })
      ];
    })
  ];

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
