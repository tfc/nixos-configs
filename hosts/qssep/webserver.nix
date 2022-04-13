{ pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services = {
    nginx = {
      enable = true;
      virtualHosts = {
        "qasm.de" = {
          enableACME = true;
          forceSSL = true;
          locations."/".root = "/var/www/qssep-root";
        };
        "downloads.qasm.de" = {
          forceSSL = true;
          useACMEHost = "qasm.de";
          locations."/".root = "/var/www/qssep-downloads";
        };
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
  security.acme.certs."qasm.de".extraDomainNames = [ "downloads.qasm.de" ];
  security.acme.certs."qssep.de".extraDomainNames = [ "downloads.qssep.de" ];
}
