{ ... }: {
  nix.daemonIOSchedPriority = 5;
}
//

if nix ? settings
then { nix.settings.trusted-users = [ "@wheel" ]; }
else { nix.trustedUsers = [ "@wheel" ]; }
