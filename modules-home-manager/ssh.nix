{ lib, pkgs, ... }:
let
  hostPart = x: builtins.elemAt (lib.strings.splitString "." x) 0;
  hostPartMapping =
    urls:
    builtins.listToAttrs (
      map (x: {
        name = hostPart x;
        value = {
          hostname = x;
          forwardAgent = true;
        };
      }) urls
    );
  defaultAsterisk = { 
    "*" = {
	forwardAgent = false;
	addKeysToAgent = "no";
	compression = false;
	serverAliveInterval = 0;
	serverAliveCountMax = 3;
	hashKnownHosts = false;
	userKnownHostsFile = "~/.ssh/known_hosts";
	controlMaster = "no";
	controlPath = "~/.ssh/master-%r@%n:%p";
	controlPersist = "no";
    };
  };
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = defaultAsterisk // hostPartMapping [
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
