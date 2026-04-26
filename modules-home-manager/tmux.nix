{ pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      xsel # for tmux-yank
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      reattach-to-user-namespace # sensible
    ];

  programs.bash.profileExtra = ''
    _tmux_rename_pwd() {
      [ -n "$TMUX" ] && tmux rename-window "''${PWD##*/}"
    }
    PROMPT_COMMAND="_tmux_rename_pwd''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  '';

  programs.zsh.initContent = ''
    _tmux_rename_pwd() {
      [ -n "$TMUX" ] && tmux rename-window "''${PWD##*/}"
    }
    chpwd_functions+=(_tmux_rename_pwd)
    _tmux_rename_pwd
  '';

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

      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
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
