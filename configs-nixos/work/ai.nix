{ config, ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  users.extraGroups.ai = { };
  users.extraUsers.ai = {
    isNormalUser = true;
    description = "AI user";
    group = "ai";
    createHome = false;
  };

  services.postgresql = {
    enable = true;
    extensions = [
      config.services.postgresql.package.pkgs.pgvector
    ];
    initialScript = builtins.toFile "postgres-initScript" ''
      CREATE ROLE ai WITH LOGIN SUPERUSER;
      CREATE DATABASE ai;
      GRANT ALL PRIVILEGES ON DATABASE ai TO ai;

      \c ai;
      CREATE EXTENSION vector;
    '';
  };
}
