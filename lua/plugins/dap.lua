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
        local root_markers = {
            ".git",
            "compile_commands.json",
            "compile_flags.txt",
            "SConstruct",
            "Makefile",
        }

        local function project_root()
            return vim.fs.root(0, root_markers) or vim.uv.cwd()
        end

        local function path_exists(path)
            return path and uv.fs_stat(vim.fn.expand(path)) ~= nil
        end

        local function add_unique(list, value)
            if not value or value == "" then
                return
            end

            for _, existing in ipairs(list) do
                if existing == value then
                    return
                end
            end

            table.insert(list, value)
        end

        local function candidate_gdb_paths(root_dir)
            local candidates = {}
            local root_candidates = {}
            local current_file = vim.api.nvim_buf_get_name(0)

            add_unique(root_candidates, root_dir)
            add_unique(root_candidates, project_root())
            add_unique(root_candidates, vim.fn.getcwd())

            if current_file ~= "" then
                add_unique(root_candidates, vim.fs.root(current_file, root_markers))
                add_unique(root_candidates, vim.fs.dirname(current_file))
            end

            for _, root in ipairs(root_candidates) do
                add_unique(candidates, root .. "/sdk/compilers/mingw-x86_64-12.2.0/bin/gdb.exe")
                for _, match in ipairs(vim.fn.glob(root .. "/sdk/compilers/**/bin/gdb.exe", false, true)) do
                    add_unique(candidates, match)
                end
            end

            for _, match in ipairs(vim.fn.glob("C:/fi-git/**/sdk/compilers/mingw-x86_64-12.2.0/bin/gdb.exe", false, true)) do
                add_unique(candidates, match)
            end

            for _, match in ipairs(vim.fn.glob("C:/fi-git/**/sdk/compilers/**/bin/gdb.exe", false, true)) do
                add_unique(candidates, match)
            end

            return candidates
        end

        local function resolve_gdb_command(root_dir)
            local candidates = {}

            for _, candidate in ipairs(candidate_gdb_paths(root_dir)) do
                add_unique(candidates, candidate)
            end

            add_unique(candidates, vim.g.gdb_executable)
            add_unique(candidates, vim.env.GDB)
            add_unique(candidates, "arm-none-eabi-gdb")
            add_unique(candidates, "gdb")

            for _, candidate in ipairs(candidates) do
                if candidate and candidate ~= "" then
                    if candidate:match("[/\\]") then
                        if path_exists(candidate) then
                            return vim.fn.expand(candidate)
                        end
                    elseif vim.fn.executable(candidate) == 1 then
                        return candidate
                    end
                end
            end

            return "gdb"
        end

        local function resolve_cppdbg_adapter()
            local candidates = {
                vim.g.cppdbg_adapter,
                "C:/Users/FIJOMAA/.vscode/extensions/ms-vscode.cpptools-1.32.2-win32-x64/debugAdapters/bin/OpenDebugAD7.exe",
            }

            for _, candidate in ipairs(candidates) do
                if candidate and candidate ~= "" and path_exists(candidate) then
                    return vim.fn.expand(candidate)
                end
            end

            for _, match in ipairs(vim.fn.glob("C:/Users/FIJOMAA/.vscode/extensions/ms-vscode.cpptools-*/debugAdapters/bin/OpenDebugAD7.exe", false, true)) do
                if path_exists(match) then
                    return match
                end
            end

            return nil
        end

        local function default_path_or_prompt(prompt, default_path)
            if path_exists(default_path) then
                return default_path
            end

            vim.notify(prompt .. " not found at " .. default_path .. ". Pick it manually.", vim.log.levels.WARN)
            return vim.fn.input(prompt .. ": ", default_path, "file")
        end

        local function pick_program()
            return vim.fn.input("Path to executable: ", project_root() .. "/", "file")
        end

        local function pick_args()
            local raw = vim.fn.input("Program arguments: ")
            if raw == "" then
                return {}
            end

            return vim.split(raw, "%s+", { trimempty = true })
        end

        dapui.setup()
        require("nvim-dap-virtual-text").setup()

        for name, sign in pairs({
            DapBreakpoint = "●",
            DapBreakpointCondition = "◆",
            DapBreakpointRejected = "",
            DapLogPoint = "󰰍",
            DapStopped = "▶",
        }) do
            vim.fn.sign_define(name, { text = sign, texthl = name, linehl = "", numhl = "" })
        end

        dap.adapters.cppdbg = {
            id = "cppdbg",
            type = "executable",
            command = assert(resolve_cppdbg_adapter(), "OpenDebugAD7.exe not found. Install ms-vscode.cpptools."),
            options = {
                detached = false,
            },
        }

        local launch_config = {
            name = "Launch with GDB",
            type = "cppdbg",
            request = "launch",
            cwd = project_root,
            program = pick_program,
            args = pick_args,
            stopAtEntry = false,
            externalConsole = false,
            MIMode = "gdb",
            miDebuggerPath = function()
                return resolve_gdb_command(project_root())
            end,
            setupCommands = {
                {
                    description = "Enable pretty-printing for gdb",
                    text = "-enable-pretty-printing",
                    ignoreFailures = true,
                },
                {
                    description = "Set disassembly flavor to Intel",
                    text = "-gdb-set disassembly-flavor intel",
                    ignoreFailures = true,
                },
            },
        }

        local unit_test_config = {
            name = "Unit test gdb launch",
            type = "cppdbg",
            request = "launch",
            cwd = project_root,
            program = function()
                local root_dir = project_root()
                return default_path_or_prompt("Unit test executable", root_dir .. "/build/unittests/motion_unit_tests.exe")
            end,
            args = {},
            stopAtEntry = false,
            externalConsole = false,
            MIMode = "gdb",
            miDebuggerPath = function()
                return resolve_gdb_command(project_root())
            end,
            setupCommands = {
                {
                    description = "Enable pretty-printing for gdb",
                    text = "-enable-pretty-printing",
                    ignoreFailures = true,
                },
                {
                    description = "Set disassembly flavor to Intel",
                    text = "-gdb-set disassembly-flavor intel",
                    ignoreFailures = true,
                },
            },
        }

        local virtual_drive_config = {
            name = "YINVC motion gdb launch",
            type = "cppdbg",
            request = "launch",
            cwd = function()
                return project_root() .. "/virtual_drive"
            end,
            program = function()
                local root_dir = project_root()
                return default_path_or_prompt("Virtual drive executable", root_dir .. "/virtual_drive/YINVC.exe")
            end,
            args = { "/debug", "/wcf", "/nodeid", "1", "/flash", "YINVC_312.vd" },
            stopAtEntry = false,
            externalConsole = false,
            MIMode = "gdb",
            miDebuggerPath = function()
                return resolve_gdb_command(project_root())
            end,
            setupCommands = {
                {
                    description = "Enable pretty-printing for gdb",
                    text = "-enable-pretty-printing",
                    ignoreFailures = true,
                },
                {
                    description = "Set disassembly flavor to Intel",
                    text = "-gdb-set disassembly-flavor intel",
                    ignoreFailures = true,
                },
            },
        }

        dap.configurations.c = { launch_config, unit_test_config, virtual_drive_config }
        dap.configurations.cpp = {
            vim.deepcopy(launch_config),
            vim.deepcopy(unit_test_config),
            vim.deepcopy(virtual_drive_config),
        }

        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end

        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end

        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end
    end,
}