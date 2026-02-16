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
        vim.env.ESLINT_D_PPID = vim.fn.getpid() -- for eslint_d
        local lint = require("lint")
        lint.linters_by_ft = {
            cpp = { "clangtidy" },
            javascript = { "eslint_d" },
            typescript = { "eslint_d" },
            sh = { "shellcheck" },
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
