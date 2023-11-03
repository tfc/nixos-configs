{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    #enableAutosuggestions = true;
    #oh-my-zsh = {
    #  enable = true;
    #  plugins = [
    #    "git"
    #    "history"
    #    "last-working-dir"
    #  ];
    #  theme = "lambda";
    #};
    shellAliases = import ./common_aliases.nix;
  };
}
