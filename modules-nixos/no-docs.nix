{ lib, ... }:

{
  documentation.enable = lib.mkForce false;
  documentation.nixos.enable = lib.mkForce false;
}
