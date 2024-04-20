-- colorscheme should be available when starting Neovim
-- always `lazy = false` and `priority = 1000`

local use = "rose_pine"

local M = {}

M.rose_pine = {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false, -- make sure we load this during startup
    cond = function(_)
        return vim.env.COLORTERM == "truecolor"
    end,
    config = function(_)
        vim.opt.termguicolors = true
        vim.cmd.colorscheme("rose-pine")
    end,
    priority = 1000 -- make sure to load this before all the other start plugins
}

return M[use]
