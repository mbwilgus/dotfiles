return {
    "ckolkey/ts-node-action",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = true,
    keys = {
        {
            mode = "n",
            "<C-K>",
            function()
                require("ts-node-action").node_action()
            end,
            desc = "Trigger node action",
            silent = true
        }
    }
}
