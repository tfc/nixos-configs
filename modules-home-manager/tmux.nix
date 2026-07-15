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

  programs.bash.bashrcExtra = ''
    _tmux_rename_pwd() {
      [ -n "$TMUX" ] && tmux rename-window -t "$TMUX_PANE" "''${PWD##*/}"
    }
    PROMPT_COMMAND="_tmux_rename_pwd''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  '';

  programs.zsh.initContent = ''
    _tmux_rename_pwd() {
      [ -n "$TMUX" ] && tmux rename-window -t "$TMUX_PANE" "''${PWD##*/}"
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
    # A 256-color terminfo inside tmux; the default is "screen" (8 colors),
    # which mangles vim-airline's truecolor output into muddy palette hues.
    terminal = "tmux-256color";
    extraConfig = ''
      set -sg escape-time 0
      set -g mouse on

      # Pass 24-bit truecolor through to the outer terminal, so neovim/vim-airline
      # (termguicolors) render the same theme-independent RGB colors inside tmux
      # as they do in a bare terminal window. Gate on $COLORTERM so RGB is only
      # advertised when the outer terminal actually supports truecolor (kitty and
      # most GUI terminals set it) -- not on a plain tty or a legacy ssh session.
      if-shell '[ "$COLORTERM" = truecolor ] || [ "$COLORTERM" = 24bit ]' \
        'set -as terminal-features ",*:RGB"'

      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Sync tmux paste buffer with the system clipboard.
      # Paste pulls the current clipboard contents into a fresh buffer first.
      bind ] run-shell "xsel -o -b | tmux load-buffer - && tmux paste-buffer"
    '';
    plugins = with pkgs.tmuxPlugins; [
      nord
      vim-tmux-navigator
      {
        plugin = yank;
        extraConfig = ''
          # Always copy to the system clipboard (not the X primary selection),
          # including mouse selections, so tmux and the system stay in sync.
          set -g @yank_selection 'clipboard'
          set -g @yank_selection_mouse 'clipboard'

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
