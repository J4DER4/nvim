return {
    enabled = true,
    "ms-jpq/coq_nvim",
    branch = "coq",
    build = ":COQdeps",
    lazy = false,
    dependencies = {
        { "ms-jpq/coq.artifacts",  branch = "artifacts" },
        { "ms-jpq/coq.thirdparty", branch = "3p" },
    },
    init = function()
        require("coq_3p")({
            { src = "nvimlua", short_name = "nLUA", conf_only = true },
        })
        -- recommended = false: manual keymaps for pumvisible set in core/extras.lua
        vim.g.coq_settings = {
            keymap = {
                recommended = false,
            },
            display = {
                preview = {
                    border = "double",
                },
            },
            completion = {
                skip_after = { '"', ")", "]", "}", "\t" },
            },
        }
    end,
}
