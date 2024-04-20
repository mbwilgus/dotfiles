return {
    "stevearc/oil.nvim",
    -- opts = {
    -- },
    config = function(_, _)
        require("oil").setup({})

        vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open parent directory" })
    end
}
