{ pkgs, ... }:

{
  services.matomo = {
    enable = true;
    package = pkgs.matomo_5;
    nginx = { };
    hostname = "matomo.nix-consulting.de";
  };
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    initialScript = builtins.toFile "initialScript.sql" ''
      CREATE DATABASE matomo;
      CREATE USER 'matomo'@'localhost' IDENTIFIED WITH unix_socket;
      GRANT ALL PRIVILEGES ON matomo.* TO 'matomo'@'localhost';
    '';
    settings = {
      mysqld = {
        max_allowed_packet = "64M";
      };
    };
  };

  services.nginx.enable = true;
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "jacek@galowicz.de";

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
