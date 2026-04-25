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
vim.cmd("syntax enable")

local function detect_background()
  local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
  if not handle then return "light" end
  local out = handle:read("*a") or ""
  handle:close()
  if out:match("prefer%-dark") then
    return "dark"
  end
  return "light"
end

local function apply_theme()
  vim.opt.background = detect_background()
  vim.cmd("colorscheme gruvbox")
end

apply_theme()

if vim.fn.executable("dconf") == 1 then
  vim.fn.jobstart({ "dconf", "watch", "/org/gnome/desktop/interface/" }, {
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line:match("color%-scheme") then
          vim.schedule(apply_theme)
          break
        end
      end
    end,
  })
end

-- Load LSP config
local lsp_config_path = vim.fn.stdpath('config') .. '/lsp.lua'
if vim.fn.filereadable(lsp_config_path) == 1 then
    dofile(lsp_config_path)
end
