{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bash-completion
    bashInteractive
  ];

  programs.bash = {
    enable = true;
    sessionVariables = {
      CLICOLOR = 1;
      LSCOLORS = "GxFxCxDxBxegedabagaced";
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
    };
    shellAliases = import ./common_aliases.nix;
    profileExtra = ''
      export PS1="\[\033[38;5;6m\]\A\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;2m\]\u\[$(tput sgr0)\]\[\033[38;5;10m\]@\[$(tput sgr0)\]\[\033[38;5;2m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;9m\]\W\[$(tput sgr0)\]\[\033[38;5;15m\] \\$\[$(tput sgr0)\] ";
      eval "$(direnv hook bash)"
    '';

  };
}
