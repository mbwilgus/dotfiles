return {
    "simrat39/rust-tools.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-nvim-lsp",
        "mfussenegger/nvim-dap"
    },
    opts = function()
        return {
            server = require("user.lsp").config.rust_analyzer,
        }
    end,
    -- can't make this VeryLazy (autocmds not run if start file is .rs?)
    -- event = "VeryLazy"
}
