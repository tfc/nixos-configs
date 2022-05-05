{ ... }:

{
  nix.trustedUsers = [ "@wheel" ];
  services.openssh.enable = true;
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
