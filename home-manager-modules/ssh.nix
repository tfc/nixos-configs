{ lib, pkgs, ... }:
let
  hostPart = x: builtins.elemAt (lib.strings.splitString "." x) 0;
  hostPartMapping = urls:
    builtins.listToAttrs (map
      (x: {
        name = hostPart x;
        value = {
          hostname = x;
          forwardAgent = true;
        };
      })
      urls);
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = hostPartMapping [
      "server-sicherheit.lxht.de"
      "training-machine.nixcademy.com"
      "build01.nix-consulting.de"
    ];
    extraConfig = lib.optionalString pkgs.stdenv.targetPlatform.isDarwin ''
      UseKeychain yes
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519
    '';
  };
}
