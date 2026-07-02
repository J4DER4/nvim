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
-- vim.keymap.set("n", "<leader><Tab>", "I<Tab><Esc>", { silent = true, desc = "Insert Tab" }) --fast insert tabI

vim.keymap.set("n", "<leader>x", ":.lua<cr>") -- execute current line (lua only)
vim.keymap.set("v", "<leader>x", ":lua<cr>") -- execute current line (lua only)

vim.keymap.set("n", "<leader>b", "<C-o>") -- jump to previous spot

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

vim.keymap.set("v", "<leader>f", function() --format visual selection
    require("conform").format({
        async = false,
        lsp_format = "never",
        range = {
            start = vim.api.nvim_buf_get_mark(0, "<"),
            ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
        },
    })
end, { desc = "Format selection" })

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
    return vim.fs.root(0, { ".git", "SConstruct", "compile_commands.json", "compile_flags.txt" }) or vim.uv.cwd()
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
vim.keymap.set("v", "<leader>sr", function()
    -- yank visual selection into register v, then pass as default_text
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg("v"):gsub("\n", "")
    require("telescope.builtin").live_grep({
        cwd = project_root(),
        default_text = text,
    })
end, { desc = "Search visual selection in repo" })
vim.keymap.set("n", "<leader>sh", "<cmd>tab Telescope help_tags<cr>", {
    desc = "Search help",
})
-- COKELINE
local map = vim.api.nvim_set_keymap
map("n", "<Tab>", "<Plug>(cokeline-focus-next)", { silent = true })
map("n", "<S-Tab>", "<Plug>(cokeline-focus-prev)", { silent = true })
vim.keymap.set("n", "<M-d>", ":bd<Cr>", { silent = true })
for i = 1, 9 do
    map("n", "<M-" .. i .. ">", "<Plug>(cokeline-focus-" .. i .. ")", { silent = true })
end
map("n", "<leader><Tab>", "<Plug>(cokeline-pick-focus)", { silent = false })

-- TELESCOPE FILE BROWSER
-- Custom git highlight groups (vivid, colorscheme-independent)
vim.api.nvim_set_hl(0, "FBGitUnstaged", { fg = "#e5c07b", bold = true }) -- yellow  : unstaged changes
vim.api.nvim_set_hl(0, "FBGitStaged", { fg = "#98c379", bold = true }) -- green   : staged / added
vim.api.nvim_set_hl(0, "FBGitDeleted", { fg = "#e06c75", bold = true }) -- red     : deleted
vim.api.nvim_set_hl(0, "FBGitUntracked", { fg = "#5c6370" }) -- gray    : untracked

local fb_git_hl = {
    unstaged = "FBGitUnstaged",
    staged = "FBGitStaged",
    deleted = "FBGitDeleted",
    untracked = "FBGitUntracked",
}

local function build_git_data(path)
    local lines = vim.fn.systemlist("git -C " .. vim.fn.shellescape(path) .. " status --branch --porcelain")
    if vim.v.shell_error ~= 0 or #lines == 0 then
        return "Files", {}
    end

    local branch = lines[1]:match("^## ([^%.%s]+)") or ""
    if branch == "" or branch == "HEAD" then
        return "Files", {}
    end

    -- XY format: X = index (staged), Y = worktree (unstaged)
    local status_map, m, a, d, u = {}, 0, 0, 0, 0
    for i = 2, #lines do
        local x, y = lines[i]:sub(1, 1), lines[i]:sub(2, 2)
        local file = vim.fn.fnamemodify(lines[i]:sub(4):gsub('"', ""), ":t")
        if file == "" then
            goto continue
        end

        local s
        if x == "?" and y == "?" then
            s = "untracked"
            u = u + 1
        elseif x ~= " " and x ~= "?" then
            -- something staged (M/A/R/C/D in index)
            if x == "D" or y == "D" then
                s = "deleted"
                d = d + 1
            else
                s = "staged"
                a = a + 1
            end
        elseif y ~= " " then
            -- only worktree change (unstaged)
            if y == "D" then
                s = "deleted"
                d = d + 1
            else
                s = "unstaged"
                m = m + 1
            end
        end
        if s then
            status_map[file] = s
        end
        ::continue::
    end
    local parts = {}
    if a > 0 then
        table.insert(parts, "+" .. a)
    end
    if m > 0 then
        table.insert(parts, "~" .. m)
    end
    if d > 0 then
        table.insert(parts, "-" .. d)
    end
    if u > 0 then
        table.insert(parts, "?" .. u)
    end
    local stat = #parts > 0 and ("  " .. table.concat(parts, " ")) or "  ✓"
    return "Files [" .. branch .. stat .. "]", status_map
end

local function apply_fb_git_hl(results_bufnr, status_map)
    if not vim.api.nvim_buf_is_valid(results_bufnr) then
        return
    end
    local ns = vim.api.nvim_create_namespace("fb_git_hl")
    vim.api.nvim_buf_clear_namespace(results_bufnr, ns, 0, -1)
    local lines = vim.api.nvim_buf_get_lines(results_bufnr, 0, -1, false)
    for row, line in ipairs(lines) do
        for name, gs in pairs(status_map) do
            if line:find(name, 1, true) then
                vim.api.nvim_buf_add_highlight(results_bufnr, ns, fb_git_hl[gs], row - 1, 0, -1)
                break
            end
        end
    end
end

vim.keymap.set("n", "<leader><leader>", function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local cwd = (bufname == "" or bufname:match("^term://")) and vim.uv.cwd() or vim.fn.expand("%:p:h")

    local title, status_map = build_git_data(cwd)

    require("telescope").extensions.file_browser.file_browser({
        path = cwd,
        prompt_title = title,
        display_stat = { size = true },
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            local fb_actions = require("telescope._extensions.file_browser.actions")

            local function open_entry()
                local entry = action_state.get_selected_entry()
                if not entry then
                    return
                end
                if entry.is_dir then
                    fb_actions.open_dir(prompt_bufnr)
                    return
                end
                actions.close(prompt_bufnr)
                vim.cmd("tabnew " .. vim.fn.fnameescape(entry.path))
            end

            actions.select_default:replace(open_entry)
            map("n", "l", open_entry)
            map("n", "h", fb_actions.goto_parent_dir)

            if next(status_map) then
                vim.schedule(function()
                    local picker = action_state.get_current_picker(prompt_bufnr)
                    if not picker then
                        return
                    end
                    local rbuf = picker.results_bufnr
                    apply_fb_git_hl(rbuf, status_map)
                    vim.api.nvim_buf_attach(rbuf, false, {
                        on_lines = function(_, buf)
                            vim.schedule(function()
                                apply_fb_git_hl(buf, status_map)
                            end)
                        end,
                    })
                end)
            end

            return true
        end,
    })
end, { desc = "Open file browser" })

--LAZYGIT
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGitCurrentFile<cr>", { silent = true })

vim.keymap.set("n", "[[", "<cmd>Gitsigns prev_hunk<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "]]", "<cmd>Gitsigns next_hunk<cr>", { noremap = true, silent = true })
--TOGGLETERM
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", {
    desc = "Terminal float",
})
vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal size=15<cr>", {
    desc = "Terminal horizontal",
})
vim.keymap.set("n", "<leader>tf", function()
    vim.cmd("tabnew")
    vim.cmd("terminal")
    vim.bo.buflisted = true
    vim.cmd("startinsert")
end, {
    desc = "Terminal tab",
})
--NOTES
vim.keymap.set("n", "<leader>n", "<cmd>e $NOTES<cr>", {
    desc = "Open notes",
})
vim.keymap.set("n", "<leader>p", function()
    local action_state = require("telescope.actions.state")
    local actions = require("telescope.actions")

    local open_in_terminal_tab = function(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if not entry then
            return
        end
        local project_path = entry.value
        actions.close(prompt_bufnr)
        vim.cmd("tabnew")
        vim.cmd("tcd " .. vim.fn.fnameescape(project_path))
        vim.cmd("terminal")
        vim.bo.buflisted = true
        vim.cmd("startinsert")
    end

    require("telescope").extensions.project.project({
        initial_mode = "normal",
        attach_mappings = function(_, map)
            map("n", "t", open_in_terminal_tab)
            map("i", "<C-t>", open_in_terminal_tab)
            return true
        end,
    })
end, { desc = "Open projects" })

--COPY path
vim.keymap.set("n", "<F4>", function()
    local path = vim.api.nvim_buf_get_name(0)
    vim.fn.setreg("+", path) -- copy to system clipboard
    print("Copied path: " .. path)
end, {
    desc = "Copy current buffer path to clipboard",
})



