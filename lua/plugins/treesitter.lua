return {
    enabled = true,
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	build = ":TSUpdate",
	config = function()
		local max_filesize = 1024 * 200 -- 200 KB
		local function disable_for_large_files(_, buf)
			local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
			return false
		end

		require("nvim-treesitter").setup({
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",
				"bash",
				"json",
				"yaml",
				"toml",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"c",
				"cpp",
				"python",
				"mermaid",
			},
			highlight = {
				enable = true,
				disable = disable_for_large_files,
			},
			indent = {
				enable = true,
				disable = disable_for_large_files,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = "<C-s>",
					node_decremental = "<M-space>",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
					},
				},
			},
			auto_install = true,
		})
	end,
}
