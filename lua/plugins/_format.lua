return { -- Formatting tool, formats files on save, fixes consistent style with indentation and line breaks.

    --IMPROTANT: make sure to run :ConformInfo to check all is good
    enabled = true,
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },

    config = function()
        local c = require("conform")
        if vim.g.formatting_enabled == nil then
            vim.g.formatting_enabled = false
        end

        local function formatting_enabled(bufnr)
            local buffer_setting = vim.b[bufnr].formatting_enabled
            if buffer_setting ~= nil then
                return buffer_setting
            end
            return vim.g.formatting_enabled
        end

        local function format_status_message(scope, enabled)
            vim.notify(scope .. " formatting " .. (enabled and "enabled" or "disabled"), vim.log.levels.INFO)
        end

        local function format_current_buffer()
            c.format({
                async = false,
                lsp_format = "never",
            })
        end

        vim.api.nvim_create_user_command("FormatToggle", function(opts)
            if opts.bang then
                local enabled = not formatting_enabled(0)
                vim.b.formatting_enabled = enabled
                format_status_message("Buffer", enabled)
                return
            end

            vim.g.formatting_enabled = not vim.g.formatting_enabled
            format_status_message("Global", vim.g.formatting_enabled)
        end, {
            bang = true,
            desc = "Toggle formatting globally or for the current buffer with !",
        })

        vim.api.nvim_create_user_command("Format", function()
            format_current_buffer()
        end, {
            desc = "Format the current buffer, ignoring formatting toggle state",
        })

        --find more @ https://github.com/stevearc/conform.nvim#formatters
        c.setup({
            formatters_by_ft = { -- IMPORTANT, These also need to be installed trough Mason (Tab 5)!
                lua = { "stylua" },
                c = { "clang-format" },
                cpp = { "clang-format" },
                python = { "black" },
            },
            format_on_save = function(bufnr)
                if not formatting_enabled(bufnr) then
                    return
                end

                return {
                    lsp_format = "never", --use lsp if format is non available
                    async = false,
                    timeout_ms = 1000,
                    quiet = false,
                }
            end,
        })
    end,
}
