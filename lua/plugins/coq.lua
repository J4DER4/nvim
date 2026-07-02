return {

    enabled = true,
    "ms-jpq/coq_nvim",
    branch = "coq",
    build = ":COQdeps",
    lazy = false,
    -- lazy = false,

    dependencies = {
        { "ms-jpq/coq.artifacts", branch = "artifacts" },
        { "ms-jpq/coq.thirdparty", branch = "3p" },
    },
    init = function()
        require("coq_3p")({
            { src = "nvimlua", short_name = "nLUA", conf_only = true },
        })
        vim.g.coq_settings = {

            auto_start = "shut-up", --test 
            keymap = {
                recommended = true,
                jump_to_mark = "<S-Tab>",
            },

            display = {
                preview = {
                    border = "double",
                },

                -- mark = false,
            },

            completion = {
                skip_after = { '"', ")", "]", "}", "\t" },
            },
        }
    end,
}
