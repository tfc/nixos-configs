{ ... }: {
  nix.daemonIOSchedPriority = 5;
  nix.settings.trusted-users = [ "@wheel" ];
}
