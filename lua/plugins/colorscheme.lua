return {
	"scottmckendry/cyberdream.nvim",
	priority = 1000,
    branch = "main",
	lazy = false,
	config = function()
		require("cyberdream").setup({
			transparent = true,
			hide_fillchars = false,
            variant = "dark"
		})
		vim.cmd([[colorscheme cyberdream]])
	end,
}
