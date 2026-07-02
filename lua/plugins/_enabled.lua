-- Plugin enable/disable registry
-- This file is the final word on whether a plugin loads.
-- Keys are plugin filenames (without .lua). Default when absent: enabled.
-- Set to false to completely skip loading a plugin.
return {
    -- LSP / completion
    _lsp          = true,
    coq           = true,
    lazydev       = true,
    signature     = true,
    fidget        = true,

    -- Formatting / linting
    _format       = true,
    _lint         = true,

    -- Debugging
    dap           = true,

    -- UI chrome
    colorscheme   = true,
    alpha         = true,
    cokeline      = true,
    lualine       = true,
    indent        = true,

    -- Navigation / search
    telescope                  = true,
    ["telescope-filebrowser"]  = true,
    ["telescope-projects"]     = true,
    trouble       = true,
    yazi          = true,

    -- Git
    gitsigns      = true,
    lazygit       = true,

    -- Editing helpers
    autopairs     = true,
    comment       = true,
    minisurround  = true,
    htmlautotag   = true,

    -- Terminal
    toggleterm    = true,

    -- Language support
    treesitter    = true,
    typst         = true,

    -- Misc
    backup        = true,
}
