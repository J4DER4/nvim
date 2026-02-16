--BASIC UTILITY
vim.keymap.set("n", "<C-j>", "5j", { noremap = true, silent = true }) -- move quickly up and down
vim.keymap.set("n", "<C-k>", "5k", { noremap = true, silent = true })

vim.keymap.set("n", "j", 'v:count == 0 ? "gj" : "j"', { expr = true, silent = true }) -- allow movement over soft wrapped lines
vim.keymap.set("n", "k", 'v:count == 0 ? "gk" : "k"', { expr = true, silent = true })

vim.keymap.set("n", "<leader>u", ":redo<CR>", { silent = false }) --fast reverse undo (redo)

vim.keymap.set("n", "<Esc>", ":noh<CR>", { silent = true })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { noremap = true, silent = true }) --Grab line and move it VISUALMODE
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { noremap = true, silent = true })

vim.keymap.set("n", "<enter>", "A<cr><esc>", { desc = "fast insert line" })
vim.keymap.set("n", "<bs>", "I<bs><esc>", { desc = "fast remove line" })
vim.keymap.set("n", "<leader><Tab>", "I<Tab><Esc>", { silent = true, desc = "Insert Tab" }) --fast insert tabI

vim.keymap.set("n", "<leader>x", ":.lua<cr>")                                               -- execute current line (lua only)
vim.keymap.set("v", "<leader>x", ":lua<cr>")                                                -- execute current line (lua only)

vim.keymap.set("n", "<leader>b", "<C-o>")                                                   -- jump to previous spot

--LSP SPESIFIC
vim.keymap.set("n", "<leader>f", function() --format by lsp
    vim.lsp.buf.format()
end)

vim.keymap.set("n", "<leader>h", function() --show function info under cursor
    vim.lsp.buf.signature_help()
end)
vim.keymap.set("n", "gd", function() --goto definition()
    vim.lsp.buf.definition()
end)
vim.keymap.set("n", "gD", function() --goto declaration()
    vim.lsp.buf.declaration()
end)
vim.keymap.set("n", "<leader>r", "<cmd>Telescope lsp_references<cr>")

-- TROUBLE
vim.keymap.set( -- toggle trouble
    "n",
    "<leader>d",
    "<cmd>Trouble diagnostics toggle focus=true<cr>",
    { desc = "toggle trouble diagnostics" }
)

--TELESCOPE
vim.keymap.set("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>") -- search fuzzy find current / to replace default search
vim.keymap.set("n", "<leader>sh", "<cmd>tab Telescope help_tags<cr>")             -- search helps
-- COKELINE
local map = vim.api.nvim_set_keymap
map("n", "<Tab>", "<Plug>(cokeline-focus-next)", { silent = true })
vim.keymap.set("n", "<M-d>", ":bd<Cr>", { silent = true })
for i = 1, 9 do
    map("n", "<M-" .. i .. ">", "<Plug>(cokeline-focus-" .. i .. ")", { silent = true })
end
-- YAZI
vim.keymap.set("n", "<leader><leader>", "<cmd>Yazi<CR>", { desc = "Open Yazi" })

--LAZYGIT
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGitCurrentFile<cr>", { silent = true })

--OCTAVE
vim.keymap.set("n", "<leader>of", ":!octave --silent %<CR>", { noremap = true })
