{ pkgs, lib, agenix, hostName, ... }:

{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = builtins.readFile ./vimrc;
    plugins = with pkgs.vimPlugins; [
      bufexplorer
      haskell-vim
      nerdtree
      purescript-vim
      vim-airline
      vim-colorschemes
      vim-nix
      vim-tmux-navigator
      vim-trailing-whitespace
    ];
  };

  home.packages = with pkgs; [
    rnix-lsp
  ];
}
