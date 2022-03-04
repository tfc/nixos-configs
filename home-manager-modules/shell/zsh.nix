{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    initExtra = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "history"
        "last-working-dir"
      ];
      theme = "lambda";
    };
    shellAliases = import ./common_aliases.nix;
    sessionVariables = {
      SHELL = "/Users/tfc/.nix-profile/bin/zsh";
      SSH_AUTH_SOCK = "~/.gnupg/S.gpg-agent.ssh";
    };
  };
}
