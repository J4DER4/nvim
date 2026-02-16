return { --:h mason-lspconfig
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        require("mason").setup()
        local lsp = require("mason-lspconfig")
        lsp.setup({
            ensure_installed = { --Add here or install trough mason
            },
            automatic_installation = true,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()

        require("mason-lspconfig").setup { --automated attach
            function(server_name)
                require("lspconfig")[server_name].setup(
                    require("coq").lsp_ensure_capabilities(capabilities)
                )
            end,
            --targetted overrireds for extra config
            --
            -- ["clangd"] = function()
            --     require("lspconfig").clangd.setup({
            --         capabilities = capabilities,
            --
            --
            --         cmd = {
            --             "clangd",
            --             "--background-index",
            --             "-j=6", --how many cores to use // adjust to your desired core amount
            --             "--query-driver=**", --adjust to any compiler
            --             "--clang-tidy", --analysis via clang tidy
            --             "--all-scopes-completion", --allows work within #ifndef scopes
            --             "--cross-file-rename", -- kinda self explanitory
            --             "--completion-style=detailed", -- better completions
            --             "--header-insertion-decorators",
            --             "--header-insertion=iwyu", -- Include What You See
            --             "--pch-storage=memory", --precompile to ram -> faster
            --             "--suggest-missing-includes",
            --         },
            --     })
            -- end,
        }
    end,
}
-- print(vim.inspect(require("coq").lsp_ensure_capabilities({})))
-- mason-lspconfig.get_installed_servers()
