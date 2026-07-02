return {
    "babarot/backup.nvim",
    config = function()
        require("backup").setup({
            backup_dir = vim.fn.expand("D:/logs/nvim-backups"),  -- Use forward slashes
            include_dir = true,
            -- your configuration here
            -- your configuration here
        })
    end,
}
