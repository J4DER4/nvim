-- DAP configuration
-- Machine-specific overrides via lua/core/local.lua:
--   vim.g.gdb_executable  = "/path/to/gdb"            (override gdb binary)
--   vim.g.cppdbg_adapter   = "/path/to/OpenDebugAD7"  (override cppdbg adapter path)
return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        local uv = vim.uv or vim.loop
        local is_win = vim.fn.has("win32") == 1

        local root_markers = { ".git", "compile_commands.json", "compile_flags.txt", "SConstruct", "Makefile" }

        local function project_root()
            return vim.fs.root(0, root_markers) or vim.uv.cwd()
        end

        local function path_exists(path)
            return path and uv.fs_stat(vim.fn.expand(path)) ~= nil
        end

        -- ----------------------------------------------------------------
        -- Resolve GDB binary
        --   1. vim.g.gdb_executable or $GDB env override
        --   2. Glob for gdb inside project sdk/compilers tree
        --   3. arm-none-eabi-gdb / gdb from PATH
        -- ----------------------------------------------------------------
        local function resolve_gdb_command()
            for _, cand in ipairs({ vim.g.gdb_executable, vim.env.GDB }) do
                if cand and cand ~= "" then
                    if cand:match("[/\\]") then
                        if path_exists(cand) then return vim.fn.expand(cand) end
                    elseif vim.fn.executable(cand) == 1 then
                        return cand
                    end
                end
            end
            local root = project_root()
            local pattern = root .. "/sdk/compilers/**/bin/gdb" .. (is_win and ".exe" or "")
            for _, match in ipairs(vim.fn.glob(pattern, false, true)) do
                if path_exists(match) then return match end
            end
            for _, cand in ipairs({ "arm-none-eabi-gdb", "gdb" }) do
                if vim.fn.executable(cand) == 1 then return cand end
            end
            return "gdb"
        end

        -- ----------------------------------------------------------------
        -- Resolve cppdbg adapter (Windows only)
        --   1. vim.g.cppdbg_adapter override
        --   2. Glob for any installed ms-vscode.cpptools extension
        -- ----------------------------------------------------------------
        local function resolve_cppdbg_adapter()
            if vim.g.cppdbg_adapter and vim.g.cppdbg_adapter ~= "" then
                if path_exists(vim.g.cppdbg_adapter) then
                    return vim.fn.expand(vim.g.cppdbg_adapter)
                end
            end
            if not is_win then return nil end
            local home = vim.fn.expand("~")
            local pattern = home .. "/.vscode/extensions/ms-vscode.cpptools-*/debugAdapters/bin/OpenDebugAD7.exe"
            for _, match in ipairs(vim.fn.glob(pattern, false, true)) do
                if path_exists(match) then return match end
            end
            return nil
        end

        local function pick_program()
            return vim.fn.input("Path to executable: ", project_root() .. "/", "file")
        end

        local function pick_args()
            local raw = vim.fn.input("Program arguments: ")
            if raw == "" then return {} end
            return vim.split(raw, "%s+", { trimempty = true })
        end

        -- ----------------------------------------------------------------
        -- Setup UI and virtual text
        -- ----------------------------------------------------------------
        dapui.setup()
        require("nvim-dap-virtual-text").setup()

        for name, sign in pairs({
            DapBreakpoint          = "●",
            DapBreakpointCondition = "◆",
            DapBreakpointRejected  = "✗",
            DapLogPoint            = "◎",
            DapStopped             = "▶",
        }) do
            vim.fn.sign_define(name, { text = sign, texthl = name, linehl = "", numhl = "" })
        end

        -- ----------------------------------------------------------------
        -- cppdbg adapter - optional, warn when not found
        -- ----------------------------------------------------------------
        local cppdbg_path = resolve_cppdbg_adapter()
        if cppdbg_path then
            dap.adapters.cppdbg = {
                id      = "cppdbg",
                type    = "executable",
                command = cppdbg_path,
                options = { detached = false },
            }
        else
            dap.adapters.cppdbg = {
                type = "executable",
                command = "false",
                enrich_config = function(_, on_config)
                    vim.notify(
                        "[dap] cppdbg adapter not found.\nInstall ms-vscode.cpptools or set vim.g.cppdbg_adapter.",
                        vim.log.levels.WARN)
                    on_config({})
                end,
            }
        end

        -- ----------------------------------------------------------------
        -- Common GDB setup commands
        -- ----------------------------------------------------------------
        local gdb_setup = {
            { description = "Enable pretty-printing", text = "-enable-pretty-printing",           ignoreFailures = true },
            { description = "Intel disassembly",      text = "-gdb-set disassembly-flavor intel", ignoreFailures = true },
        }

        local launch_config = {
            name            = "Launch with GDB",
            type            = "cppdbg",
            request         = "launch",
            cwd             = project_root,
            program         = pick_program,
            args            = pick_args,
            stopAtEntry     = false,
            externalConsole = false,
            MIMode          = "gdb",
            miDebuggerPath  = resolve_gdb_command,
            setupCommands   = gdb_setup,
        }

        dap.configurations.c   = { launch_config }
        dap.configurations.cpp = { vim.deepcopy(launch_config) }

        dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
        dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
        dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
    end,
}
