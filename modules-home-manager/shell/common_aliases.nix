{
  ".." = "cd ..";
  ll = "ls -lsa";
  nfu = "nix flake update";
  nfuc = "nix flake update --commit-lock-file";
  npu = "NIXPKGS_ALLOW_UNFREE=1 nix profile upgrade --all --impure";
  nrn = "nix repl --file '<nixpkgs>'";
  sdn = ''statix fix; deadnix -e; find . -name "*.nix" -exec nixfmt {} \;'';
}
