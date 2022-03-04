{
  ".." = "cd ..";
  ll = "ls -lsa";
  nrn = "nix repl '<nixpkgs>'";
  nrnc = "nix repl '<nixpkgs/nixos>'";
  nix-build-koma = "nix-build --option extra-substituters https://binary-cache.vpn.cyberus-technology.de --option trusted-public-keys binary-cache.vpn.cyberus-technology.de:qhg25lVqyCT4sDOqxY6GJx8NF3F86eAJFCQjZK/db7Y= ";
  nix-update = "sudo nix-channel --update && nix-channel --update && sudo nixos-rebuild switch && home-manager switch";
  manix-search = "manix '' | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview=\"manix '{}'\" | xargs manix";
}
