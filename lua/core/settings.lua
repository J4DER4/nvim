vim.o.clipboard = "unnamedplus"
vim.o.mouse = "a"
vim.o.breakindent = true
vim.opt.syntax = "on"
vim.opt.showmode = false
vim.o.termguicolors = true
vim.o.completeopt = "menu,noselect"

--swapfiles
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

--save undo history
vim.o.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

--search
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

--signcolums & left stuff
vim.wo.signcolumn = "yes"
vim.wo.number = true
vim.opt.relativenumber = true
vim.opt.ruler = true
vim.opt.cursorline = true
--autoread file updates
vim.opt.autoread = false

-- Indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
local spaces = 4
vim.opt.tabstop = spaces
vim.opt.softtabstop = spaces
vim.opt.shiftwidth = spaces
vim.opt.expandtab = true

-- Linewrap
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = "↳"

-- scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 15
vim.opt.sidescroll = 5

-- lazy redraw stuff
vim.opt.lazyredraw = false

vim.lsp.set_log_level("warn")
