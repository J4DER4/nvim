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

local function set_terminal_keymaps(bufnr)
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "<Esc><Tab>", [[<C-\><C-n><Tab>]], vim.tbl_extend("force", opts, { remap = true }))
    vim.keymap.set("t", "<Esc><S-Tab>", [[<C-\><C-n><S-Tab>]], vim.tbl_extend("force", opts, { remap = true }))
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    vim.keymap.set("n", "<Tab>", "<Plug>(cokeline-focus-next)", opts)
    vim.keymap.set("n", "<S-Tab>", "<Plug>(cokeline-focus-prev)", opts)
end

vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter" }, {
    pattern = "term://*",
    callback = function(event)
        set_terminal_keymaps(event.buf)
    end,
})

--LSP SPESIFIC
vim.keymap.set("n", "<leader>f", function() --format by lsp
    local buffer_setting = vim.b.formatting_enabled
    local formatting_enabled = buffer_setting ~= nil and buffer_setting or vim.g.formatting_enabled ~= false
    if not formatting_enabled then
        vim.notify("Formatting is disabled. Use :FormatToggle to enable it.", vim.log.levels.INFO)
        return
    end

    require("conform").format({
        async = false,
        lsp_format = "never",
    })
end, { desc = "Format current buffer" })

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

--DEBUG
vim.keymap.set("n", "<F5>", function()
    require("dap").continue()
end, { desc = "Debug continue" })
vim.keymap.set("n", "<F10>", function()
    require("dap").step_over()
end, { desc = "Debug step over" })
vim.keymap.set("n", "<F11>", function()
    require("dap").step_into()
end, { desc = "Debug step into" })
vim.keymap.set("n", "<F12>", function()
    require("dap").step_out()
end, { desc = "Debug step out" })
vim.keymap.set("n", "<leader>db", function()
    require("dap").toggle_breakpoint()
end, { desc = "Debug toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug conditional breakpoint" })
vim.keymap.set("n", "<leader>dc", function()
    require("dap").continue()
end, { desc = "Debug continue" })
vim.keymap.set("n", "<leader>dr", function()
    require("dap").repl.toggle()
end, { desc = "Debug REPL" })
vim.keymap.set("n", "<leader>du", function()
    require("dapui").toggle()
end, { desc = "Debug UI" })
vim.keymap.set("n", "<leader>dl", function()
    require("dap").run_last()
end, { desc = "Debug run last" })

-- TROUBLE
vim.keymap.set( -- toggle trouble
    "n",
    "<leader>d",
    "<cmd>Trouble diagnostics toggle focus=true<cr>",
    { desc = "toggle trouble diagnostics" }
)

local function project_root()
    return vim.fs.root(0, { ".git", "SConstruct", "compile_commands.json", "compile_flags.txt" })
        or vim.uv.cwd()
end

--TELESCOPE
vim.keymap.set("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", {
    desc = "Search current buffer",
})
vim.keymap.set("n", "<leader>sf", function()
    require("telescope.builtin").find_files({
        cwd = project_root(),
    })
end, { desc = "Search repo files" })
vim.keymap.set("n", "<leader>sr", function()
    require("telescope.builtin").live_grep({
        cwd = project_root(),
    })
end, { desc = "Search within repo files" })
vim.keymap.set("n", "<leader>sh", "<cmd>tab Telescope help_tags<cr>", {
    desc = "Search help",
})
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

--TOGGLETERM
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", {
    desc = "Terminal float",
})
vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal size=15<cr>", {
    desc = "Terminal horizontal",
})
vim.keymap.set("n", "<leader>tt", function()
    vim.cmd("tabnew")
    vim.cmd("terminal")
    vim.bo.buflisted = true
    vim.cmd("startinsert")
end, {
    desc = "Terminal tab",
})

--OCTAVE
if vim.fn.executable("octave") == 1 then
    vim.keymap.set("n", "<leader>of", ":!octave --silent %<CR>", { noremap = true })
end
