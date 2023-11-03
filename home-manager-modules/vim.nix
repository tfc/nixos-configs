{ pkgs, lib, agenix, hostName, ... }:

{
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    extraConfig = builtins.readFile ./vim-configs/vimrc;
    plugins = with pkgs.vimPlugins; [
      plenary-nvim # dep of haskell-tools.nvim
      purescript-vim
      telescope-nvim
      vim-colorschemes
      vim-nix
      {
        plugin = vimtex;
        config = ''
          let g:vimtex_view_automatic = 0
          let g:vimtex_fold_enabled = v:true
          let  g:vimtex_fold_types = {
           \ 'envs' : {
           \   'blacklist' : [
           \     'block',
           \     'center',
           \     'item',
           \     'itemize',
           \     'lstlisting',
           \     'tabular',
           \     'varblock',
           \   ],
           \ },
           \}
           let g:vimtex_quickfix_ignore_filters = [
           \ 'Underfull',
           \ 'Overfull',
           \]
        '';
      }
      vim-tmux-navigator
      {
        plugin = bufexplorer;
        config = "nnoremap <silent> <F4> :ToggleBufExplorer<CR>";
      }
      {
        plugin = haskell-vim;
        config = ''
          let g:haskell_classic_highlighting = 1
          let g:haskell_indent_if = 2
          let g:haskell_indent_case = 2
          let g:haskell_indent_let = 2
          let g:haskell_indent_where = 2
          let g:haskell_indent_before_where = 2
          let g:haskell_indent_after_bare_where = 2
          let g:haskell_indent_do = 2
          let g:haskell_indent_in = 1
          let g:haskell_indent_guard = 2
          let g:haskell_indent_case_alternative = 1
          let g:cabal_indent_section = 2
        '';
      }
      {
        plugin = nerdtree;
        config = ''
          autocmd StdinReadPre * let s:std_in=1
          autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

          let g:NERDTreeDirArrows = 1
          let g:NERDTreeMinimalUI = 1
          let g:NERDTreeMouseMode = 2
          let g:NERDTreeQuitOnOpen = 1
          let g:NERDTreeWinSize = 60

          nnoremap <silent> <F3> :NERDTreeToggle<CR>
        '';
      }
      {
        plugin = nvim-lspconfig;
        config = ''
          :luafile ${./vim-configs/lsp.lua}

          if executable('rnix-lsp')
            au User lsp_setup call lsp#register_server({
              \ 'name': 'rnix',
              \ 'cmd': {server_info->[&shell, &shellcmdflag, 'rnix-lsp']},
              \ 'whitelist': ['nix'],
              \ })
          endif
        '';
      }
      {
        plugin = vim-airline;
        config = ''
          set laststatus=2
        '';
      }
      {
        plugin = vim-better-whitespace;
        config = ''
          let g:better_whitespace_enabled = 1
          let g:strip_whitespace_on_save = 1
          let g:strip_whitespace_confirm = 0
          let g:strip_whitelines_at_eof = 1
          let g:show_spaces_that_precede_tabs = 1
          let g:better_whitespace_filetypes_blacklist = ['diff', 'git', 'gitcommit', 'unite', 'qf', 'help', 'fugitive']
        '';
      }
    ];
  };

  home.packages = with pkgs; [
    rnix-lsp
    nodePackages_latest.bash-language-server
    nodePackages_latest.pyright
    ltex-ls
    ccls
  ];
}
