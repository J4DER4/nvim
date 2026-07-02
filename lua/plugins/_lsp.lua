return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "ms-jpq/coq_nvim",
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {},
            automatic_installation = false,
        })

        local uv = vim.uv or vim.loop

        local repo_root      = "C:/fi-git/UNICOS_Industrial_ACS880INU"
        local current_target = "YINFC"  -- changed by :ClangdTarget

        -- ----------------------------------------------------------------
        -- helpers
        -- ----------------------------------------------------------------
        local function file_exists(path)
            local stat = uv.fs_stat(path)
            return stat and stat.type == "file"
        end

        local function dir_exists(path)
            local stat = uv.fs_stat(path)
            return stat and stat.type == "directory"
        end

        local function normalize_path(path)
            return path:gsub("\\", "/")
        end

        local function is_inside(path, parent)
            path   = normalize_path(path):lower()
            parent = normalize_path(parent):lower()
            return path == parent or path:sub(1, #parent + 1) == parent .. "/"
        end

        -- ----------------------------------------------------------------
        -- Auto-detect highest ACS880-vN build folder under C:/Build/
        -- Returns the folder path, e.g. "C:/Build/ACS880-v15"
        -- ----------------------------------------------------------------
        local function detect_acs880_root()
            local base = "C:/Build"
            local handle = uv.fs_scandir(base)
            if not handle then return nil end

            local best_ver = -1
            local best_path = nil

            while true do
                local name, typ = uv.fs_scandir_next(handle)
                if not name then break end
                if (typ == "directory" or typ == "link") then
                    local ver = name:match("^[Aa][Cc][Ss]880%-v(%d+)$")
                    if ver then
                        ver = tonumber(ver)
                        if ver > best_ver then
                            best_ver  = ver
                            best_path = base .. "/" .. name
                        end
                    end
                end
            end

            return best_path  -- nil if nothing found
        end

        -- ----------------------------------------------------------------
        -- Resolve clangd binary:
        --   1. ACS880-vN/LLVM/bin/clangd.exe  (preferred – matches toolchain)
        --   2. WinGet install
        --   3. Mason fallback
        --   4. PATH
        -- ----------------------------------------------------------------
        local function resolve_clangd_binary(acs880_root)
            local candidates = {}

            if acs880_root then
                table.insert(candidates, acs880_root .. "/LLVM/bin/clangd.exe")
            end

            table.insert(candidates,
                "C:/Users/FIJOMAA/AppData/Local/Microsoft/WinGet/Packages/"
                .. "LLVM.clangd_Microsoft.Winget.Source_8wekyb3d8bbwe/"
                .. "clangd_22.1.0/bin/clangd.exe")

            table.insert(candidates,
                vim.fn.stdpath("data") .. "/mason/packages/clangd/clangd_22.1.0/bin/clangd.exe")

            for _, c in ipairs(candidates) do
                if file_exists(c) then
                    return c
                end
            end

            return "clangd"  -- last resort: PATH
        end

        -- ----------------------------------------------------------------
        -- Capabilities (coq or plain)
        -- ----------------------------------------------------------------
        local function make_capabilities()
            local caps = vim.lsp.protocol.make_client_capabilities()
            local ok, coq = pcall(require, "coq")
            -- if ok then caps = coq.lsp_ensure_capabilities(caps) end
            return caps
        end

        -- ----------------------------------------------------------------
        -- Root dir: pin to monorepo root when inside it
        -- ----------------------------------------------------------------
        local function clangd_root_dir(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if is_inside(fname, repo_root) then
                on_dir(repo_root)
                return
            end
            local markers = {
                "compile_commands.json", "compile_flags.txt",
                ".clangd", ".clang-tidy", ".clang-format",
                "SConstruct", ".git",
            }
            local found = vim.fs.root(bufnr, markers)
            if found then on_dir(found) end
        end

        -- ----------------------------------------------------------------
        -- Build the command for a given target
        -- ----------------------------------------------------------------
        local toolchain_base = "C:/Build"
        local acs880_root    = detect_acs880_root()

        if not acs880_root then
            vim.notify("[clangd] WARNING: No ACS880-vN folder found under " .. toolchain_base, vim.log.levels.WARN)
        end

        local clangd_bin   = resolve_clangd_binary(acs880_root)
        local query_driver = acs880_root and (acs880_root .. "/**/*") or (toolchain_base .. "/**/*")

        -- make_clangd_cmd closes over clangd_bin / query_driver so :ClangdToolchain
        -- can reassign those upvalues and the new cmd picks them up automatically.
        local function make_clangd_cmd(target)
            return {
                clangd_bin,
                "--background-index",
                "--all-scopes-completion",
                "--cross-file-rename",
                "--completion-style=detailed",
                "--pch-storage=memory",
                "--compile-commands-dir=" .. repo_root .. "/build/" .. target .. "/",
                "--query-driver=" .. query_driver,
                "--header-insertion=never",
                "--log=error",
            }
        end

        if not dir_exists(repo_root .. "/build/" .. current_target) then
            vim.notify(
                "[clangd] build/" .. current_target .. " missing — run build first",
                vim.log.levels.ERROR)
        end

        -- ----------------------------------------------------------------
        -- Register with nvim-lsp
        -- ----------------------------------------------------------------
        vim.lsp.config("clangd", {
            cmd          = make_clangd_cmd(current_target),
            capabilities = make_capabilities(),
            root_dir     = clangd_root_dir,
            root_markers = {
                "SConstruct", ".clangd", "compile_commands.json",
                "compile_flags.txt", ".clang-tidy", ".clang-format", ".git",
            },
            init_options = {
                clangdFileStatus = true,
                hints = {
                    parameterNames = true,
                    deducedTypes   = true,
                },
            },
        })

        vim.lsp.enable("clangd")

        -- ================================================================
        -- OmniSharp for C#
        -- ================================================================
        vim.lsp.config("omnisharp", {
          cmd = { "OmniSharp", "-z", "--hostPID", vim.fn.getpid(), "--encoding", "utf-8", "--languageserver" },
          capabilities = make_capabilities(),
          root_markers = { ".sln", ".csproj" },
        })

        vim.lsp.enable("omnisharp")

        -- ----------------------------------------------------------------
        -- :ClangdTarget [TARGET]  — switch CDB target and restart
        --   no arg: prints current target
        -- ----------------------------------------------------------------
        vim.api.nvim_create_user_command("ClangdTarget", function(opts)
            local target = opts.args ~= "" and opts.args or nil
            if not target then
                vim.notify("[clangd] Current target: " .. current_target, vim.log.levels.INFO)
                return
            end
            if not dir_exists(repo_root .. "/build/" .. target) then
                vim.notify("[clangd] build/" .. target .. " not found — run build first", vim.log.levels.WARN)
                return
            end
            current_target = target
            vim.lsp.config("clangd", { cmd = make_clangd_cmd(target) })
            vim.cmd("LspRestart clangd")
            vim.notify("[clangd] Target → " .. target .. " (restarting)", vim.log.levels.INFO)
        end, { nargs = "?", desc = "Switch clangd compile_commands target" })

        -- ----------------------------------------------------------------
        -- :ClangdToolchain [ACS880-vN]  — switch toolchain version and restart
        --   no arg: prints current toolchain root
        -- ----------------------------------------------------------------
        vim.api.nvim_create_user_command("ClangdToolchain", function(opts)
            local arg = opts.args ~= "" and opts.args or nil
            if not arg then
                vim.notify("[clangd] Current toolchain: " .. (acs880_root or "(none)"), vim.log.levels.INFO)
                return
            end
            local new_root = toolchain_base .. "/" .. arg
            if not dir_exists(new_root) then
                vim.notify("[clangd] " .. new_root .. " not found", vim.log.levels.WARN)
                return
            end
            acs880_root  = new_root
            clangd_bin   = resolve_clangd_binary(acs880_root)
            query_driver = acs880_root .. "/**/*"
            vim.lsp.config("clangd", { cmd = make_clangd_cmd(current_target) })
            vim.cmd("LspRestart clangd")
            vim.notify("[clangd] Toolchain → " .. arg .. ", binary: " .. clangd_bin .. " (restarting)", vim.log.levels.INFO)
        end, { nargs = "?", desc = "Switch clangd toolchain (ACS880-vN)" })

        -- ----------------------------------------------------------------
        -- <leader>i — toggle inlay hints for current buffer
        -- ----------------------------------------------------------------
        vim.keymap.set("n", "<leader>i", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
            vim.notify("[clangd] Inlay hints " .. (not enabled and "ON" or "OFF"), vim.log.levels.INFO)
        end, { desc = "Toggle inlay hints" })
    end,
}

