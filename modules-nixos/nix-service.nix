_: {
  nix.daemonIOSchedPriority = 5;
  nix.settings = {
    connect-timeout = 5;
    log-lines = 25; # this is more than default
    trusted-users = [ "@wheel" ];
    fallback = true;
  };
}
