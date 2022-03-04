{ ... }: {
  # comment out due to limited availability as it's VPN-gated
  # nix.binaryCaches = [ "https://binary-cache.vpn.cyberus-technology.de" ];
  nix.binaryCachePublicKeys = [ "binary-cache.vpn.cyberus-technology.de:qhg25lVqyCT4sDOqxY6GJx8NF3F86eAJFCQjZK/db7Y=" ];
}
