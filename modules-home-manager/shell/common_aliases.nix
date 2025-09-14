{
  ".." = "cd ..";
  fpi = "nix flake init -t github:hercules-ci/flake-parts";
  ll = "ls -lsa";
  npu = "NIXPKGS_ALLOW_UNFREE=1 nix profile upgrade --all --impure";
  nrn = "nix repl --file '<nixpkgs>'";
}
