return {
    url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        -- SEE: h: rainbow-delimeter.setup (not sure how I feel about this...)
        -- Some people prefer to call a Lua `setup` function.  This is a bad practice
        -- carried over from a time when Lua support in Neovim still had issues with Vim
        -- script interoperability, but it has persisted through cargo-culting.
        -- Nevertheless, a setup function is available as a Lua module.

        -- This module contains a number of default definitions
        local rainbow_delimiters = require("rainbow-delimiters")

        vim.g.rainbow_delimiters = {
            strategy = {
                [""] = rainbow_delimiters.strategy["global"],
                commonlisp = rainbow_delimiters.strategy["local"],
            },
            query = {
                [""] = "rainbow-delimiters",
                lua = "rainbow-blocks",
            },
            highlight = {
                "RainbowDelimiterRed",
                "RainbowDelimiterYellow",
                "RainbowDelimiterBlue",
                "RainbowDelimiterOrange",
                "RainbowDelimiterGreen",
                "RainbowDelimiterViolet",
                "RainbowDelimiterCyan",
            },
            -- blacklist = { "c", "cpp" },
        }
    end,
}
