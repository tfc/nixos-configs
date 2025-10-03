{
  containers = {
    database = {
      autoStart = true;
      config =
        { pkgs, ... }:
        {
          services.postgresql.enable = true;
          environment.systemPackages = [
            pkgs.nettools
          ];
        };
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.2";
    };
    webserver = {
      autoStart = true;
      config = {
        services.httpd.enable = true;
        networking.firewall.enable = false;
      };
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.3";
    };
  };
}
