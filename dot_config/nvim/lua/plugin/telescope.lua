return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        config = true
    },
    -- {
    --     'nvim-telescope/telescope-fzf-native.nvim',
    --     dependencies = 'nvim-telescope/telescope.nvim',
    --     config = function()
    --         local status, mod = pcall(require, 'telescope')
    --         if status then mod.load_extension('fzf') end
    --     end,
    --     build = 'make',
    -- }
}
