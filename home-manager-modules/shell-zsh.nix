{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = import ./shell/common_aliases.nix;
  };
}
