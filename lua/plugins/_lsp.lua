-- LSP configuration
-- Machine-specific overrides via lua/core/local.lua:
--   vim.g.clangd_repo_root     = "/path/to/project"   (enables project pinning + --compile-commands-dir)
--   vim.g.clangd_target        = "MYTARGET"            (build/<target>/compile_commands.json)
--   vim.g.clangd_toolchain_base = "C:/Build"           (Windows: scan for ACS880-vN toolchain)
--   vim.g.omnisharp_enabled    = true                  (opt-in OmniSharp for C#)
return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {},
            automatic_installation = false,
        })

        local uv = vim.uv or vim.loop
        local is_win = vim.fn.has("win32") == 1

        -- ----------------------------------------------------------------
        -- Helpers
        -- ----------------------------------------------------------------
        local function file_exists(path)
            local s = uv.fs_stat(path)
            return s and s.type == "file"
        end

        local function dir_exists(path)
            local s = uv.fs_stat(path)
            return s and s.type == "directory"
        end

        local function normalize(path)
            return path:gsub("\\", "/")
        end

        local function is_inside(path, parent)
            path   = normalize(path):lower()
            parent = normalize(parent):lower()
            return path == parent or path:sub(1, #parent + 1) == parent .. "/"
        end

        -- ----------------------------------------------------------------
        -- Auto-detect highest ACS880-vN folder under a base directory
        -- (Windows toolchain convention; skipped unless clangd_toolchain_base set)
        -- ----------------------------------------------------------------
        local function detect_acs880_root(base)
            if not base then return nil end
            local handle = uv.fs_scandir(base)
            if not handle then return nil end
            local best_ver, best_path = -1, nil
            while true do
                local name, typ = uv.fs_scandir_next(handle)
                if not name then break end
                if typ == "directory" or typ == "link" then
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
            return best_path
        end

        -- ----------------------------------------------------------------
        -- Resolve clangd binary:
        --   1. ACS880 toolchain  (Windows + clangd_toolchain_base)
        --   2. Mason wrapper     (cross-platform, version-agnostic)
        --   3. PATH fallback
        -- Returns: binary path, acs880_root (or nil)
        -- ----------------------------------------------------------------
        local function resolve_clangd_binary()
            if is_win and vim.g.clangd_toolchain_base then
                local acs880 = detect_acs880_root(vim.g.clangd_toolchain_base)
                if acs880 then
                    local bin = acs880 .. "/LLVM/bin/clangd.exe"
                    if file_exists(bin) then return bin, acs880 end
                end
            end
            local ext = is_win and ".cmd" or ""
            local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/clangd" .. ext
            if file_exists(mason_bin) then return mason_bin, nil end
            return "clangd", nil  -- PATH
        end

        -- ----------------------------------------------------------------
        -- Root dir: pin to project root when inside it, else standard markers
        -- ----------------------------------------------------------------
        local root_markers = {
            "compile_commands.json", "compile_flags.txt",
            ".clangd", ".clang-tidy", ".clang-format",
            "SConstruct", ".git",
        }

        local function clangd_root_dir(bufnr, on_dir)
            local repo_root = vim.g.clangd_repo_root
            if repo_root then
                local fname = vim.api.nvim_buf_get_name(bufnr)
                if is_inside(fname, repo_root) then
                    on_dir(repo_root)
                    return
                end
            end
            local found = vim.fs.root(bufnr, root_markers)
            if found then on_dir(found) end
        end

        -- ----------------------------------------------------------------
        -- Build clangd command — closes over clangd_bin/acs880_root so
        -- :ClangdToolchain can update upvalues and restart picks them up
        -- ----------------------------------------------------------------
        local clangd_bin, acs880_root = resolve_clangd_binary()
        local current_target = vim.g.clangd_target or nil

        local function make_clangd_cmd(target)
            local cmd = {
                clangd_bin,
                "--background-index",
                "--all-scopes-completion",
                "--cross-file-rename",
                "--completion-style=detailed",
                "--pch-storage=memory",
                "--header-insertion=never",
                "--log=error",
            }

            -- compile_commands only when project root + target are configured
            local repo_root = vim.g.clangd_repo_root
            if repo_root and target then
                local cdb_dir = repo_root .. "/build/" .. target .. "/"
                if dir_exists(cdb_dir) then
                    table.insert(cmd, "--compile-commands-dir=" .. cdb_dir)
                else
                    vim.notify(
                        "[clangd] build/" .. target .. " missing — run build first",
                        vim.log.levels.WARN)
                end
            end

            -- query-driver only when a toolchain root is known
            if acs880_root then
                table.insert(cmd, "--query-driver=" .. acs880_root .. "/**/*")
            end

            return cmd
        end

        -- ----------------------------------------------------------------
        -- Register clangd with nvim-lsp
        -- ----------------------------------------------------------------
        vim.lsp.config("clangd", {
            cmd          = make_clangd_cmd(current_target),
            capabilities = vim.lsp.protocol.make_client_capabilities(),
            root_dir     = clangd_root_dir,
            root_markers = root_markers,
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
        -- OmniSharp for C# — opt-in via vim.g.omnisharp_enabled = true
        -- Explicitly disabled by default: lspconfig v3 registers all server
        -- configs globally via vim.lsp.config(), so without an explicit
        -- vim.lsp.disable() the server shows as "configured" even when we
        -- never called vim.lsp.enable().
        -- ================================================================
        if vim.g.omnisharp_enabled then
            vim.lsp.config("omnisharp", {
                cmd = {
                    "OmniSharp", "-z",
                    "--hostPID", tostring(vim.fn.getpid()),
                    "--encoding", "utf-8",
                    "--languageserver",
                },
                capabilities = vim.lsp.protocol.make_client_capabilities(),
                root_markers  = { ".sln", ".csproj" },
            })
            vim.lsp.enable("omnisharp")
        else
            pcall(vim.lsp.disable, "omnisharp")
        end

        -- ----------------------------------------------------------------
        -- :ClangdTarget [TARGET]  — switch compile_commands target and restart
        --   no arg: print current target
        -- ----------------------------------------------------------------
        vim.api.nvim_create_user_command("ClangdTarget", function(opts)
            local target = opts.args ~= "" and opts.args or nil
            if not target then
                vim.notify("[clangd] Current target: " .. (current_target or "(none)"), vim.log.levels.INFO)
                return
            end
            local repo_root = vim.g.clangd_repo_root
            if repo_root and not dir_exists(repo_root .. "/build/" .. target) then
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
        --   no arg: print current toolchain
        -- ----------------------------------------------------------------
        vim.api.nvim_create_user_command("ClangdToolchain", function(opts)
            local arg = opts.args ~= "" and opts.args or nil
            if not arg then
                vim.notify("[clangd] Toolchain: " .. (acs880_root or "(none)") .. "  binary: " .. clangd_bin, vim.log.levels.INFO)
                return
            end
            local base = vim.g.clangd_toolchain_base
            if not base then
                vim.notify("[clangd] vim.g.clangd_toolchain_base not set", vim.log.levels.WARN)
                return
            end
            local new_root = base .. "/" .. arg
            if not dir_exists(new_root) then
                vim.notify("[clangd] " .. new_root .. " not found", vim.log.levels.WARN)
                return
            end
            acs880_root = new_root
            local new_bin = new_root .. "/LLVM/bin/clangd.exe"
            clangd_bin  = file_exists(new_bin) and new_bin or "clangd"
            vim.lsp.config("clangd", { cmd = make_clangd_cmd(current_target) })
            vim.cmd("LspRestart clangd")
            vim.notify("[clangd] Toolchain → " .. arg .. "  binary: " .. clangd_bin .. " (restarting)", vim.log.levels.INFO)
        end, { nargs = "?", desc = "Switch clangd toolchain (ACS880-vN)" })

        -- ----------------------------------------------------------------
        -- <leader>i — toggle inlay hints for current buffer
        -- ----------------------------------------------------------------
        vim.keymap.set("n", "<leader>i", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
            vim.notify("[lsp] Inlay hints " .. (not enabled and "ON" or "OFF"), vim.log.levels.INFO)
        end, { desc = "Toggle inlay hints" })
    end,
}

