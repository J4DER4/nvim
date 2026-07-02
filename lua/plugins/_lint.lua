return {
    enabled = true,
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        -- Only register clangtidy when the binary is actually present
        local clang_tidy_linters = vim.fn.executable("clang-tidy") == 1
            and { "clangtidy" }
            or {}

        lint.linters_by_ft = {
            c      = clang_tidy_linters,
            cpp    = clang_tidy_linters,
            lua    = { "luacheck" },
            python = { "ruff" },
        }

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = vim.api.nvim_create_augroup("lint", { clear = true }),
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
