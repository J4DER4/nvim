vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", {}),
    desc = "Hightlight selection on yank",
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
    end,
})
vim.diagnostic.config({ -- displays on errors on screen, sources from lsp and lint
    severity_sort = true,
    update_in_insert = false,

    virtual_text = {
        spacing = 4, -- Space between text and code
        style = "minimal",
        prefix = "", -- Custom prefix (e.g., "●", "", "x")
        format = function(diagnostic)
            return string.format("%s", diagnostic.message)
        end,
    },
})

require("editorconfig")

-- Popup menu colors (vibrant dark magenta + green)
vim.cmd("highlight Pmenu      guifg=#ffffff guibg=#1e2124") -- White text, dark bg
vim.cmd("highlight PmenuSel   guifg=#ffffff guibg=#8a2f8a gui=bold") -- Dark magenta selection
vim.cmd("highlight PmenuSbar  guibg=#3c4048") -- Scrollbar track (neutral dark)
vim.cmd("highlight PmenuThumb guibg=#5eff6c") -- Vibrant green thumb
-- AUTOPAIRS COQ PATCH
local remap = vim.api.nvim_set_keymap
local npairs = require("nvim-autopairs")

npairs.setup({ map_bs = false, map_cr = false })

vim.g.coq_settings = { keymap = { recommended = false } }

-- these mappings are coq recommended mappings unrelated to nvim-autopairs
remap("i", "<esc>", [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
remap("i", "<c-c>", [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
remap("i", "<tab>", [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
remap("i", "<s-tab>", [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })

-- skip it, if you use another global object
_G.MUtils = {}

MUtils.CR = function()
    if vim.fn.pumvisible() ~= 0 then
        if vim.fn.complete_info({ "selected" }).selected ~= -1 then
            return npairs.esc("<c-y>")
        else
            return npairs.esc("<c-e>") .. npairs.autopairs_cr()
        end
    else
        return npairs.autopairs_cr()
    end
end
remap("i", "<cr>", "v:lua.MUtils.CR()", { expr = true, noremap = true })

MUtils.BS = function()
    if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ "mode" }).mode == "eval" then
        return npairs.esc("<c-e>") .. npairs.autopairs_bs()
    else
        return npairs.autopairs_bs()
    end
end
remap("i", "<bs>", "v:lua.MUtils.BS()", { expr = true, noremap = true })
