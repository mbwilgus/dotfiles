-- NOTE: from h: terminal-input

-- Terminal-mode forces these local options:

--     'cursorlineopt' = number
--     'nocursorcolumn'
--     'scrolloff' = 0
--     'sidescrolloff' = 0

-- window options
vim.opt_local.number = false
vim.opt_local.relativenumber = false

-- FIX: source of insert on dapui enter
-- start terminal in terminal-mode
-- SEE: :h terminal-mode-index
-- vim.cmd.startinsert()
