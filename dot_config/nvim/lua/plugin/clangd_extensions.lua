return {
    url = "https://git.sr.ht/~p00f/clangd_extensions.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-nvim-lsp"
    },
    -- config = true,
    -- can't make this VeryLazy (autocmds not run if start file is .c<??>?)
    -- event = "VeryLazy"
}
