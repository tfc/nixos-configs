{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    xsel # for tmux-yank
  ] ++ lib.optional pkgs.stdenv.isDarwin [
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

      set -g status-left ""
      set -g status-right '#[fg=colour233,bg=colour241,bold] %d.%m. #[fg=colour233,bg=colour245,bold] %H:%M:%S '
      set -g status-right-length 50
      set -g status-left-length 20
    '';
    plugins = with pkgs.tmuxPlugins; [
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
