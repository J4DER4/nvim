return {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = {
        "ToggleTerm",
        "ToggleTermToggleAll",
        "TermExec",
        "TermNew",
        "TermSelect",
    },
    config = function()
        require("toggleterm").setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                end

                if term.direction == "vertical" then
                    return math.floor(vim.o.columns * 0.4)
                end
            end,
            shade_terminals = false,
            start_in_insert = false,
            persist_mode = false,
            direction = "float",
            float_opts = {
                border = "single",
            },
            on_open = function(term)
                if term.window == vim.api.nvim_get_current_win() then
                    vim.cmd("startinsert")
                end
            end,
        })
    end,
}