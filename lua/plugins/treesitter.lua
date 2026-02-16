return {
    enabled = true,
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "lua", "mermaid" }, -- Languages
			highlight = { enable = true }, -- Syntax highlighting
			indent = { enable = true }, -- Smart indentation
			incremental_selection = { enable = true }, -- Ctrl+n to expand selections
			auto_install = true,
		})
	end,
}
