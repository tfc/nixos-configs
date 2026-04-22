{ pkgs, ... }:

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
    withRuby = false;
    withPython3 = false;
    initLua = builtins.readFile ./vim-configs/init.lua;
    plugins = with pkgs.vimPlugins; [
      plenary-nvim # dep of haskell-tools.nvim
      nvim-lspconfig
      haskell-tools-nvim
      purescript-vim
      telescope-nvim
      vim-colorschemes
      vim-nix
      vim-tmux-navigator
      {
        plugin = bufexplorer;
        config = "vim.keymap.set('n', '<F4>', ':ToggleBufExplorer<CR>', { silent = true })";
        type = "lua";
      }
      {
        plugin = nerdtree;
        config = ''
          vim.api.nvim_create_autocmd("StdinReadPre", {
            pattern = "*",
            callback = function() vim.g.std_in = 1 end,
          })
          vim.api.nvim_create_autocmd("VimEnter", {
            pattern = "*",
            callback = function()
              if vim.fn.argc() == 0 and not vim.g.std_in then
                vim.cmd("NERDTree")
              end
            end,
          })

          vim.g.NERDTreeDirArrows = 1
          vim.g.NERDTreeMinimalUI = 1
          vim.g.NERDTreeMouseMode = 2
          vim.g.NERDTreeQuitOnOpen = 1
          vim.g.NERDTreeWinSize = 60

          vim.keymap.set('n', '<F3>', ':NERDTreeToggle<CR>', { silent = true })
        '';
        type = "lua";
      }
      {
        plugin = vim-airline;
        config = "vim.opt.laststatus = 2";
        type = "lua";
      }
      {
        plugin = vim-better-whitespace;
        config = ''
          vim.g.better_whitespace_enabled = 1
          vim.g.strip_whitespace_on_save = 1
          vim.g.strip_whitespace_confirm = 0
          vim.g.strip_whitelines_at_eof = 1
          vim.g.show_spaces_that_precede_tabs = 1
          vim.g.better_whitespace_filetypes_blacklist = { 'diff', 'git', 'gitcommit', 'unite', 'qf', 'help', 'fugitive' }
        '';
        type = "lua";
      }
    ];
  };

  xdg.configFile."nvim/lsp.lua".text = builtins.readFile ./vim-configs/lsp.lua;

  home.packages = with pkgs; [
    bash-language-server
    ccls
    nixd
    nixfmt
  ];
}
