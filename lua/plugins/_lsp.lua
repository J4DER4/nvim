return { --:h mason-lspconfig
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        require("mason").setup()
        local lsp = require("mason-lspconfig")
        local coq = require("coq")
        local uv = vim.uv or vim.loop

        local function file_exists(path)
            local stat = uv.fs_stat(path)
            return stat and stat.type == "file"
        end

        local function resolve_clangd_binary()
            local candidates = {
                "C:/Users/FIJOMAA/AppData/Local/Microsoft/WinGet/Packages/LLVM.clangd_Microsoft.Winget.Source_8wekyb3d8bbwe/clangd_22.1.0/bin/clangd.exe",
                vim.fn.stdpath("data") .. "/mason/packages/clangd/clangd_22.1.0/bin/clangd.exe",
                "clangd",
            }

            for _, candidate in ipairs(candidates) do
                if candidate == "clangd" or file_exists(candidate) then
                    return candidate
                end
            end
        end

        local function find_compile_commands_dir(root_dir)
            if not root_dir then
                return nil
            end

            local candidates = {
                root_dir,
                root_dir .. "/build",
                root_dir .. "/Build",
                root_dir .. "/out/build",
                root_dir .. "/cmake-build-debug",
                root_dir .. "/cmake-build-release",
            }

            for _, candidate in ipairs(candidates) do
                if uv.fs_stat(candidate .. "/compile_commands.json") then
                    return candidate
                end
            end
        end

        local function make_clangd_cmd(root_dir)
            local cmd = {
                resolve_clangd_binary(),
                "--background-index",
                "--clang-tidy",
                "--query-driver=C:/fi-git/**/sdk/compilers/**/bin/*g++.exe,C:/fi-git/**/sdk/compilers/**/bin/*gcc*.exe,C:/fi-git/**/sdk/compilers/**/bin/*c++.exe",
                "--all-scopes-completion",
                "--cross-file-rename",
                "--completion-style=detailed",
                "--header-insertion-decorators",
                "--header-insertion=iwyu",
                "--pch-storage=memory",
                "--suggest-missing-includes",
            }

            local compile_commands_dir = find_compile_commands_dir(root_dir)
            if compile_commands_dir then
                table.insert(cmd, "--compile-commands-dir=" .. compile_commands_dir)
            end

            return cmd
        end

        lsp.setup({
            ensure_installed = { --Add here or install trough mason
            },
            automatic_installation = true,
        })

        vim.lsp.config("*", coq.lsp_ensure_capabilities({}))

        vim.lsp.config("clangd", {
            cmd = make_clangd_cmd(vim.fn.getcwd()),
            root_markers = {
                ".clangd",
                ".clang-tidy",
                ".clang-format",
                "compile_commands.json",
                "compile_flags.txt",
                "configure.ac",
                ".git",
            },
        })
    end,
}
