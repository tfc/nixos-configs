{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = import ./common_aliases.nix;
  };
}
