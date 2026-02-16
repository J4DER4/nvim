return {
    enabled = true,
	"mikavilpas/yazi.nvim",
	dependencies = { "noib3/nvim-cokeline" },
	config = function()
		require("yazi").setup({
			-- Open files in Neovim tabs instead of buffers
			open_for_directories = false, -- Don't open directories in Yazi
			range = function(paths)
				-- Convert Yazi-selected files into Neovim tabs
				for _, path in ipairs(paths) do
					vim.cmd("tabnew " .. path)
				end
			end,
		})
	end,
}
