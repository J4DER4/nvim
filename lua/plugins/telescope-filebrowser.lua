return {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local telescope = require("telescope")

        telescope.setup({
            extensions = {
                file_browser = {
                    initial_mode = "normal",
                    hidden = { file_browser = true, folder_browser = true },
                    grouped = true,
                    hijack_netrw = false,
                    display_stat = { size = true },
                },
            },
        })

        telescope.load_extension("file_browser")
    end,
}
