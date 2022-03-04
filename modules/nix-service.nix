{ ... }: {
  nix.daemonIOSchedPriority = 5;
  nix.trustedUsers = [ "@wheel" ];
}
