return {
    enabled = true,
    "mfussenegger/nvim-lint",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "emilienlemaire/clang-tidy.nvim",
    },
    event = {
        "BufReadPre",
        "BufNewFile",
    },
    config = function()
        require("clang-tidy")
        local lint = require("lint")
        lint.linters_by_ft = {
            c = { "clangtidy" },
            cpp = { "clangtidy" },
            lua = { "luacheck" },
            python = { "ruff" },
        }
        -- lint.linters.clangtidy = {
        -- 	cmd = "clang-tidy",
        -- }
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
