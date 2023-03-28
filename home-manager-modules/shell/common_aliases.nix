{
  ".." = "cd ..";
  ll = "ls -lsa";
  nrn = "nix repl --file '<nixpkgs>'";
  nrnc = "nix repl --file '<nixpkgs/nixos>'";
  manix-search = "manix '' | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview=\"manix '{}'\" | xargs manix";
}
