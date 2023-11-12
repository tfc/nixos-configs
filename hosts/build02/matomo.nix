{ pkgs, ... }:

{
  services.matomo = {
    enable = true;
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
  };

  services.nginx.enable = true;
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "jacek@galowicz.de";

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
