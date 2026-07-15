{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    sessionVariables = {
      CLICOLOR = 1;
      LSCOLORS = "GxFxCxDxBxegedabagaced";
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
    };
    shellAliases = import ./shell/common_aliases.nix;
    # PS1 lives in bashrcExtra (not profileExtra) so it applies to every
    # interactive shell, not just login shells.
    # Colors use 24-bit truecolor (\033[38;2;R;G;Bm) rather than ANSI palette
    # indices 0-15 (\033[38;5;Nm). Indices 0-15 are repainted by the terminal
    # color theme (e.g. kitty's 3024_Night), which made the hues look muddy;
    # truecolor is theme-independent, so the prompt looks the same everywhere.
    # RGB values are the classic Tango palette.
    bashrcExtra = ''
      export PS1="\[\033[38;2;6;152;154m\]\A\[$(tput sgr0)\]\[\033[38;2;238;238;236m\] \[$(tput sgr0)\]\[\033[38;2;78;154;6m\]\u\[$(tput sgr0)\]\[\033[38;2;138;226;52m\]@\[$(tput sgr0)\]\[\033[38;2;78;154;6m\]\h\[$(tput sgr0)\]\[\033[38;2;238;238;236m\] \[$(tput sgr0)\]\[\033[38;2;239;41;41m\]\W\[$(tput sgr0)\]\[\033[38;2;238;238;236m\] \\$\[$(tput sgr0)\] ";
    '';

  };
}
