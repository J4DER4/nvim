-- Minimal Neovim config for testing TypeScript LSP
vim.cmd('set shortmess+=c')  -- Avoid "pattern not found" messages

-- Install packer.nvim if not present
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
  vim.cmd('packadd packer.nvim')
end

-- Load plugins (only LSP essentials)
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'  -- Package manager
  use 'neovim/nvim-lspconfig'   -- LSP configuration
  use 'williamboman/mason.nvim'  -- LSP installer
  use 'williamboman/mason-lspconfig.nvim'  -- Bridge Mason & LSP
end)

-- Configure LSP
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'tsserver' },  -- Force install tsserver
})

-- Basic LSP setup for tsserver
local lspconfig = require('lspconfig')
lspconfig.tsserver.setup({})

-- Auto-start LSP when opening a TypeScript file
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'typescript', 'javascript' },
  callback = function()
    vim.lsp.start({ name = 'tsserver' })
  end,
})

-- Keymaps for LSP (optional but helpful for testing)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to Definition' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename Symbol' })
