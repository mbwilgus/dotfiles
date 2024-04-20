-- buffer options
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

local ok, lint = pcall(require, 'lint')
if not ok then return end

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'InsertLeave', 'TextChanged' }, { buffer = vim.fn.bufnr(), callback = function() lint.try_lint('shellcheck') end })
