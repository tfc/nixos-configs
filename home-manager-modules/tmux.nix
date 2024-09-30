{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xsel # for tmux-yank
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    reattach-to-user-namespace # sensible
  ];

  programs.tmux = {
    aggressiveResize = true;
    clock24 = true;
    enable = true;
    historyLimit = 5000;
    keyMode = "vi";
    newSession = true;
    sensibleOnTop = true;
    extraConfig = ''
      set -sg escape-time 0
      set -g mouse on
    '';
    plugins = with pkgs.tmuxPlugins; [
      nord
      tmux-colors-solarized
      vim-tmux-navigator
      {
        plugin = yank;
        extraConfig = ''
          bind -T copy-mode    C-c send -X copy-pipe-no-clear "xsel -i --clipboard"
          bind -T copy-mode-vi C-c send -X copy-pipe-no-clear "xsel -i --clipboard"
        '';
      }
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
    ];
  };
}
