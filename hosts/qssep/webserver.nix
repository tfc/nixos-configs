{ pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services = {
    nginx = {
      enable = true;
      virtualHosts = {
        "qssep.de" = {
          enableACME = true;
          forceSSL = true;
          locations."/".root = "/var/www/qssep-root";
        };
        "downloads.qssep.de" = {
          forceSSL = true;
          useACMEHost = "qssep.de";
          locations."/".root = "/var/www/qssep-downloads";
        };
      };
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "jacek@galowicz.de";
  security.acme.certs."qssep.de".extraDomainNames = [ "downloads.qssep.de" ];
}
