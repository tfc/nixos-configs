{ lib, ... }:

{
  nix.settings.trusted-users = [ "@wheel" ];
  services.openssh.enable = true;
  security.sudo.enable = lib.mkDefault true;
  security.sudo.wheelNeedsPassword = false;
}
