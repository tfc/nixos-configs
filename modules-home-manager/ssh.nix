{ lib, pkgs, ... }:
let
  hostPart = x: builtins.elemAt (lib.strings.splitString "." x) 0;
  hostPartMapping =
    urls:
    builtins.listToAttrs (
      map (x: {
        name = hostPart x;
        value = {
          HostName = x;
          ForwardAgent = true;
        };
      }) urls
    );
  defaultAsterisk = {
    "*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
  };
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings =
      defaultAsterisk
      // hostPartMapping [
        "server-sicherheit.lxht.de"
        "training-machine.nixcademy.com"
      ];
    extraConfig = lib.optionalString pkgs.stdenv.targetPlatform.isDarwin ''
      IgnoreUnknown AddKeysToAgent,UseKeychain
      UseKeychain yes
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519
    '';
  };
}
