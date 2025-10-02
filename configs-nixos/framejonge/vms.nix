{
  microvm.vms = {
    vm1 = {
      config = {
        systemd.network.networks."11-microvm" = {
          matchConfig.Name = "vm-*";
          networkConfig.Bridge = "microvm";
        };

        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };

        users.users.root.initialPassword = "lol";

        microvm = {
          interfaces = [
            {
              type = "user";
              id = "vm1";
              mac = "00:00:00:00:00:01";
            }
          ];
          forwardPorts = [
            { from = "host"; host.port = 2222; guest.port = 22; }
          ];
        };
      };
    };
  };

  systemd.network.netdevs."10-microvm".netdevConfig = {
    Kind = "bridge";
    Name = "microvm";
  };
  systemd.network.networks."10-microvm" = {
    matchConfig.Name = "microvm";

    networkConfig = {
      DHCPServer = true;
      IPv6SendRA = true;
    };

    addresses = [
      {
        addressConfig.Address = "10.0.0.1/24";
      }
      {
        addressConfig.Address = "fd12:3456:789a::1/64";
      }
    ];
    ipv6Prefixes = [
      {
        ipv6PrefixConfig.Prefix = "fd12:3456:789a::/64";
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 67 ];

  networking.nat = {
    enable = true;
    enableIPv6 = true;

    externalInterface = "wlp192s0";
    internalInterfaces = [ "microvm" ];
  };
}
