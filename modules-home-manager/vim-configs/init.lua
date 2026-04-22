-- Modern Neovim configuration in Lua

-- Leader key
vim.g.mapleader = ","

-- Key mappings
vim.keymap.set('n', '<leader>w', ':w!<CR>')
vim.keymap.set('n', '<F2>', 'za')

-- Options
local opt = vim.opt

opt.autoindent = true
opt.autoread = true
opt.backspace = { "eol", "start", "indent" }
opt.cmdheight = 2
opt.colorcolumn = "80"
opt.completeopt:append("longest")
opt.confirm = true
opt.expandtab = true
opt.exrc = true
opt.fileformats = { "unix", "dos", "mac" }
opt.history = 1000
opt.hlsearch = true
opt.ignorecase = true
opt.incsearch = true
opt.lazyredraw = true
opt.linebreak = true
opt.list = true
opt.listchars = { tab = "▷⋅", trail = "⋅", nbsp = "⋅" }
opt.mouse = "a"
opt.backup = false
opt.errorbells = false
opt.foldenable = false
opt.swapfile = false
opt.visualbell = false
opt.writebackup = false
opt.number = true
opt.ruler = true
opt.secure = true
opt.shiftwidth = 2
opt.showcmd = true
opt.showmatch = true
opt.showmode = true
opt.smartindent = true
opt.smartcase = true
opt.smarttab = true
opt.tabstop = 2
opt.timeoutlen = 500
opt.textwidth = 500
opt.wildignore:append({ "*/tmp/*", "*.swp", "*.swo", "*.zip", ".git", ".cabal-sandbox" })
opt.wildignore:append({ "*.o", "*.obj", "*~" })
opt.wildignore:append({ "*.o", "*~", "*.pyc" })
opt.wildmenu = true
opt.wildmode = { "longest", "list", "full" }
opt.wrap = true

-- GUI options
opt.guioptions:remove("L")
opt.guioptions:remove("T")
opt.guioptions:remove("m")
opt.guioptions:remove("r")

-- Appearance
opt.termguicolors = true
opt.background = "light"
vim.cmd("syntax enable")
vim.cmd("colorscheme gruvbox")

-- Load LSP config
local lsp_config_path = vim.fn.stdpath('config') .. '/lsp.lua'
if vim.fn.filereadable(lsp_config_path) == 1 then
    dofile(lsp_config_path)
end
