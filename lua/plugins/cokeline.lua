return {
    "noib3/nvim-cokeline",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local coke = require("cokeline")
        local hlgroups = require("cokeline.hlgroups")

        coke.setup({
            show_if_buffers_are_at_least = 2,

            default_hl = {
                fg = function(buffer)
                    return buffer.is_focused and hlgroups.get_hl_attr("TabLineSel", "fg")
                        or hlgroups.get_hl_attr("TabLineFill", "fg")
                end,
                bg = function(buffer)
                    return buffer.is_focused and hlgroups.get_hl_attr("TabLineSel", "bg")
                        or hlgroups.get_hl_attr("TabLineFill", "bg")
                end,
            },

            components = {
                {
                    text = function(buffer)
                        return " " .. buffer.devicon.icon
                    end,
                    fg = function(buffer)
                        return buffer.devicon.color
                    end,
                },
                {
                    text = function(buffer)
                        if buffer.is_focused then
                            return ""
                        end

                        return buffer.index .. ". "
                    end,
                },
                {
                    text = function(buffer)
                        return buffer.unique_prefix
                    end,
                    fg = hlgroups.get_hl_attr("Directory", "fg"),
                    style = "italic",
                },
                {
                    text = function(buffer)
                        return buffer.filename .. " "
                    end,
                },
            },
        })
    end,
}
