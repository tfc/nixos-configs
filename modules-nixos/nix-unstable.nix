{ pkgs, ... }:

{
  nix.package = pkgs.nixVersions.latest;

  nix.settings.auto-allocate-uids = true;

  nix.settings.experimental-features = [
    "dynamic-derivations"
    "auto-allocate-uids"
    "ca-derivations"
    "cgroups"
    "blake3-hashes"
  ];

  nix.settings.extra-system-features = [
    "uid-range"
    "devnet"
  ];

  nix.settings.extra-sandbox-paths = [
    "/dev/net"
  ];
}
