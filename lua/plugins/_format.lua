return { -- Formatting tool, formats files on save, fixes consistent style with indentation and line breaks.

    --IMPROTANT: make sure to run :ConformInfo to check all is good
    enabled = true,
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },

    config = function()
        local c = require("conform")
        --find more @ https://github.com/stevearc/conform.nvim#formatters
        c.setup({
            formatters_by_ft = { -- IMPORTANT, These also need to be installed trough Mason (Tab 5)!
                html = { "prettier" },
                js = { "prettier" },
                jsx = { "prettier" },
                tsx = { "prettier" },
                sh = {"beautysh"},
                typst= {"prettypst"},
                asm = {"asmfmt"}
                -- cpp = { "clang-format" },
            },
            format_on_save = {
                lsp_format = "never", --use lsp if format is non available

                async = false,
                timeout_ms = 1000,
                quiet = false,
            },
        })
    end,
}
