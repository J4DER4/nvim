return {
    enabled = true,
    "folke/trouble.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "Trouble" },
    opts = {
        auto_close = false,
        auto_preview = true,
    },
}
