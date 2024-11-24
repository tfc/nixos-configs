{ pkgs, ... }:

let
  gitlabRunner = { registrationConfigFile, extraPkgs ? [ ], tagList ? [ ] }: {
    inherit registrationConfigFile;
    dockerImage = "alpine";
    dockerVolumes = [
      "/nix/store:/nix/store:ro"
      "/nix/var/nix/db:/nix/var/nix/db:ro"
      "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
    ];
    dockerDisableCache = true;
    preBuildScript = pkgs.writeScript "setup-container" ''
      mkdir -p -m 0755 /nix/var/log/nix/drvs
      mkdir -p -m 0755 /nix/var/nix/gcroots
      mkdir -p -m 0755 /nix/var/nix/profiles
      mkdir -p -m 0755 /nix/var/nix/temproots
      mkdir -p -m 0755 /nix/var/nix/userpool
      mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
      mkdir -p -m 1777 /nix/var/nix/profiles/per-user
      mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
      mkdir -p -m 0700 "$HOME/.nix-defexpr"

      . ${pkgs.nix}/etc/profile.d/nix.sh

      ${pkgs.nix}/bin/nix-env -i ${pkgs.lib.concatStringsSep " " (with pkgs; [ nix cacert git openssh ] ++ extraPkgs)}
    '';
    environmentVariables = {
      ENV = "/etc/profile";
      USER = "root";
      NIX_REMOTE = "daemon";
      PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
      NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
    };
    inherit tagList;
  };

in

{
  virtualisation.docker.enable = true;

  services.gitlab-runner = {
    enable = true;
    services = {
      sevenNix = gitlabRunner {
        registrationConfigFile = "/var/secrets/gitlab-seven";
        tagList = [ "nix" ];
      };
    };
  };
}
