{ config, ... }:

{
  networking.firewall.allowedTCPPorts = [
    config.services.grafana.settings.server.http_port
  ];

  services.grafana = {
    enable = true;

    settings.server.http_addr = "::";

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:${toString config.services.prometheus.port}";
        }
      ];
    };
  };

  services.prometheus = {
    enable = true;

    scrapeConfigs = [
      {
        job_name = "homeautomation";
        static_configs =
          let
            f = port: { targets = [ "localhost:${builtins.toString port}" ]; };
            ports = [
              config.services.prometheus.exporters.node.port
              config.services.prometheus.exporters.systemd.port
            ];
          in
          map f ports;
      }
    ];
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [
        "conntrack"
        "diskstats"
        "entropy"
        "filefd"
        "filesystem"
        "interrupts"
        "ksmd"
        "loadavg"
        "logind"
        "mdadm"
        "meminfo"
        "netdev"
        "netstat"
        "stat"
        "systemd"
        "time"
        "vmstat"
      ];
    };

    systemd = {
      enable = true;
      extraFlags = [
        # Disabled by default because only supported from systemd 235+
        "--systemd.collector.enable-restart-count"
        "--systemd.collector.enable-ip-accounting"
      ];
    };
  };
}
