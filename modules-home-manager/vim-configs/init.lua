-- Modern Neovim configuration in Lua

-- Leader key
vim.g.mapleader = ","

-- Key mappings
vim.keymap.set('n', '<leader>w', ':w!<CR>')
vim.keymap.set('n', '<F2>', 'za')

-- Telescope fuzzy finder
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Telescope: find files' })
vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = 'Telescope: live grep' })
vim.keymap.set('n', '<leader>fb', telescope.buffers, { desc = 'Telescope: buffers' })
vim.keymap.set('n', '<leader>fh', telescope.help_tags, { desc = 'Telescope: help tags' })

-- Options
local opt = vim.opt

opt.autoindent = true
opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.bufexists("[Command Line]") == 0 then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk, buffer reloaded", vim.log.levels.WARN)
  end,
})
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

-- Ask the XDG desktop portal for the system colour preference: 0 = no
-- preference, 1 = dark, 2 = light. Both GNOME and KDE implement this, unlike
-- the gsettings/dconf route used before, which reported light on Plasma
-- because gsettings ships with GNOME and simply isn't there otherwise.
-- Anything short of an explicit "light" stays dark, matching the
-- noPreference => adwaita_darker choice kitty makes in desktop.nix.
local function detect_background()
  local handle = io.popen(
    "busctl --user call org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop "
      .. "org.freedesktop.portal.Settings ReadOne ss "
      .. "org.freedesktop.appearance color-scheme 2>/dev/null"
  )
  if not handle then return "dark" end
  local out = handle:read("*a") or ""
  handle:close()
  return out:match("v%s+u%s+2") and "light" or "dark"
end

local function apply_theme()
  vim.opt.background = detect_background()
  vim.cmd("colorscheme gruvbox")
end

apply_theme()

-- The portal signals every settings change, so filter for the colour one.
if vim.fn.executable("busctl") == 1 then
  vim.fn.jobstart({
    "busctl",
    "--user",
    "monitor",
    "--match=type='signal',interface='org.freedesktop.portal.Settings',member='SettingChanged'",
  }, {
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
