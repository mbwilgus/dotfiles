local term_settings = vim.api.nvim_create_augroup('term_settings', { clear = true })

-- give terminals a filetype so that options can be set in `after/ftplugin/stdio.lua`
vim.api.nvim_create_autocmd('TermOpen', {
    group = term_settings,
    pattern = '*',
    callback = function()
        vim.opt_local.filetype = 'stdio'
    end
})
