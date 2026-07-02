-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ----------------------------------------------------------------
-- Build plugin spec list, gated by plugins/_enabled.lua registry.
-- Any file in lua/plugins/ whose basename (no .lua) is mapped to
-- false in the registry is silently skipped.
-- Default when a key is absent: enabled.
-- ----------------------------------------------------------------
local function load_plugins()
    local ok, registry = pcall(require, "plugins._enabled")
    if not ok then registry = {} end

    local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
    local specs = {}

    for _, file in ipairs(vim.fn.glob(plugin_dir .. "/*.lua", false, true)) do
        local name = vim.fn.fnamemodify(file, ":t:r")
        if name ~= "_enabled" then
            local enabled = registry[name]
            if enabled == nil then enabled = true end  -- unlisted = enabled
            if enabled then
                local spec_ok, spec = pcall(require, "plugins." .. name)
                if spec_ok and type(spec) == "table" then
                    table.insert(specs, spec)
                end
            end
        end
    end

    return specs
end

require("lazy").setup({
    spec    = load_plugins(),
    install = { colorscheme = { "cyberdream" } },
    checker = { enabled = true, notify = false },
})

