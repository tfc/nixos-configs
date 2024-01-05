{ lib, ... }:
let
  hostPart = x: builtins.elemAt (lib.strings.splitString "." x) 0;
  hostPartMapping = urls:
    builtins.listToAttrs (map (x: { name = hostPart x; value = { hostname = x; }; }) urls);
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = hostPartMapping [
      "server-sicherheit.lxht.de"
      "training-machine.nixcademy.com"
    ];
  };
}
