{ pkgs, ... }:

{
  nix.package = pkgs.nixVersions.latest;

  nix.settings.auto-allocate-uids = true;

  nix.settings.experimental-features = [
    "auto-allocate-uids"
    "ca-derivations"
    "cgroups"
  ];

  nix.settings.extra-system-features = [
    "uid-range"
  ];
}
