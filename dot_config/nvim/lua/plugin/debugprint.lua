return {
    "andrewferrier/debugprint.nvim",
    config = true,
    cmd = "DeleteDebugPrints",
    keys = {
        {
            "g?p",
            mode = "n"
        },
        {
            "g?P",
            mode = "n"
        },
        {
            "g?v",
            mode = { "n", "x" }
        },
        {
            "g?V",
            mode = "n"
        },
        {
            "g?o",
            mode = "o"
        },
        {
            "g?O",
            mode = "o"
        }
    }
}
