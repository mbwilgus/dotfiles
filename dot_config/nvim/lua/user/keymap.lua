vim.g.mapleader = " "

local helper = require("user.helper")

local opts = { silent = true }
local expr_opts = vim.tbl_extend("force", opts, { expr = true })

-- don't use arrow keys in normal mode
vim.keymap.set("n", "<Left>", "<C-W>h", opts)
vim.keymap.set("n", "<Down>", "<C-W>j", opts)
vim.keymap.set("n", "<Right>", "<C-W>l", opts)
vim.keymap.set("n", "<Up>", "<C-W>k", opts)

vim.keymap.set("n", "<Leader><Leader>", vim.cmd.update, opts)
vim.keymap.set("i", "jk", "<Esc>", opts)

local map_relative_jump = function(direction, mark_threshold)
    return function()
        local jump = vim.v.count < 2 and string.format("g%s", direction) or
            vim.v.count < mark_threshold and string.format("%d%s", vim.v.count, direction) or
            string.format("m`%d%s", vim.v.count, direction)

        vim.cmd.normal({
            args = { jump },
            bang = true
        })
    end
end

vim.keymap.set("n", "j", map_relative_jump("j", 20), opts)
vim.keymap.set("n", "k", map_relative_jump("k", 20), opts)

-- delete/change into the void
vim.keymap.set("n", "<Leader>c", "\"_c", opts)
vim.keymap.set("n", "<Leader>d", "\"_d", opts)

-- delete empty lines into the void
vim.keymap.set("n", "dd", function()
    if vim.api.nvim_get_current_line():match("^%s*$") then
        return "\"_dd"
    end
    return "dd"
end, expr_opts)

local put_blank = function(count, after)
    local lines = {}
    for _ = 1, count do
        table.insert(lines, "")
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    vim.api.nvim_put(lines, "l", after, false)

    row = after and row or row + count
    vim.api.nvim_win_set_cursor(0, { row, col })
end

vim.keymap.set("n", "<CR>", function()
    if vim.bo.modifiable then
        put_blank(vim.v.count1, true)
    else
        vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
    end
end, opts)

vim.keymap.set("n", "<S-CR>", function()
    if vim.bo.modifiable then
        put_blank(vim.v.count1, false)
    else
        vim.api.nvim_feedkeys(vim.keycode("<S-CR>"), "n", false)
    end
end, opts)

vim.keymap.set("n", "<C-CR>", function()
    if vim.bo.modifiable then
        put_blank(1, true)
        put_blank(1, false)
    else
        vim.api.nvim_feedkeys(vim.keycode("<C-CR>"), "n", false)
    end
end, opts)

-- switch the semantics of <C-R> and <C-R><C-O>.
-- the latter inserts text from a register literally, _without_ auto indenting or otherwise formatting
vim.keymap.set("i", "<C-R>", "<C-R><C-O>", opts)
vim.keymap.set("i", "<C-R><C-O>", "<C-R>", opts)

-- navigate arglist
local arg_maps = {
    {
        mode = "n",
        lhs  = "]a",
        rhs  = helper.map_counted_exec("next"),
        desc = "Edit file [count] in the argument list",
        opts = opts
    },
    {
        mode = "n",
        lhs  = "[a",
        rhs  = helper.map_counted_exec("previous"),
        desc = "Edit [count] previous file in argument list",
        opts = opts
    },
    {
        mode = "n",
        lhs  = "]A",
        rhs  = helper.map_exec("last"),
        desc = "Start editing the last file in the argument list",
        opts = opts
    },
    {
        mode = "n",
        lhs  = "[A",
        rhs  = helper.map_exec("first"),
        desc = "Start editing the first file in the argument list",
        opts = opts
    }
}

helper.keymap_table(arg_maps)

-- navigate buffers
local buf_maps = {
    {
        mode = "n",
        lhs  = "]b",
        rhs  = helper.map_counted_exec("bnext"),
        desc = "Go to [count] next buffer in the buffer list",
        opts = opts
    },
    {
        mode = "n",
        lhs  = "[b",
        rhs  = helper.map_counted_exec("bprevious"),
        desc = "Go to [count] previous buffer in the buffer list",
        opts = opts
    },
    {
        mode = "n",
        lhs  = "]B",
        rhs  = helper.map_exec("blast"),
        desc = "Go to the last buffer in the buffer list",
        opts = opts
    },
    {
        mode = "n",
        lhs  = "[B",
        rhs  = helper.map_exec("bfirst"),
        desc = "Go to the first buffer in the buffer list",
        opts = opts
    }
}

helper.keymap_table(buf_maps)
