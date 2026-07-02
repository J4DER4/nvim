-- nvim-treesitter main branch (v2 rewrite) -- completely different API from master.
-- NO require('nvim-treesitter.configs').setup{} -- that module no longer exists.
-- Highlighting: Neovim built-in via vim.treesitter.start(), enabled per FileType.
-- Textobjects: direct module calls, keymaps set manually.
return {
    enabled = true,
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,  -- required; plugin does not support lazy-loading
    build = ":TSUpdate",
    dependencies = {
        { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function()
        local parsers = {
            "lua", "vim", "vimdoc", "query",
            "markdown", "markdown_inline",
            "bash", "json", "yaml", "toml",
            "javascript", "typescript", "tsx",
            "html", "css",
            "c", "cpp",
            "python",
        }

        -- New setup: only install_dir needed (auto-prepended to rtp by the plugin)
        require("nvim-treesitter").setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        -- Install parsers (async, idempotent -- safe to call every startup)
        require("nvim-treesitter").install(parsers)

        -- Enable treesitter highlighting per filetype (built-in Neovim feature)
        -- Skip for large files
        local max_filesize = 200 * 1024
        vim.api.nvim_create_autocmd("FileType", {
            pattern = parsers,
            callback = function(args)
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
                if ok and stats and stats.size > max_filesize then return end
                pcall(vim.treesitter.start, args.buf)
            end,
        })

        -- ----------------------------------------------------------------
        -- Textobjects (nvim-treesitter-textobjects main branch)
        -- All config via direct module calls -- no configs.setup() wrapper.
        -- ----------------------------------------------------------------
        require("nvim-treesitter-textobjects").setup({
            select = { lookahead = true },
            move   = { set_jumps = true },
        })

        local sel  = require("nvim-treesitter-textobjects.select")
        local move = require("nvim-treesitter-textobjects.move")

        -- Select text objects
        for lhs, query in pairs({
            af = "@function.outer", ["if"] = "@function.inner",
            ac = "@class.outer",    ic    = "@class.inner",
        }) do
            vim.keymap.set({ "x", "o" }, lhs, function()
                sel.select_textobject(query, "textobjects")
            end)
        end

        -- Move between text objects
        for lhs, args in pairs({
            ["]f"] = { move.goto_next_start,     "@function.outer" },
            ["[f"] = { move.goto_previous_start, "@function.outer" },
            ["]c"] = { move.goto_next_start,     "@class.outer"    },
            ["[c"] = { move.goto_previous_start, "@class.outer"    },
        }) do
            vim.keymap.set({ "n", "x", "o" }, lhs, function()
                args[1](args[2], "textobjects")
            end)
        end
    end,
}
