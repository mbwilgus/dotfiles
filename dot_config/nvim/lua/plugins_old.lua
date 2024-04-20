local packer_path = 'site/pack/packer/start/packer.nvim'
local install_path = vim.fn.stdpath('data') .. packer_path


if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = vim.fn.system({
        'git', 'clone', '--depth', '1',
        'https://github.com/wbthomason/packer.nvim', install_path
    })
end

-- compile plugin configuration (i.e., this file) when changed
-- vim.cmd([[
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost plugins.lua source <afile> | PackerCompile
--   augroup END
-- ]])

-- use a protected call so we don't error out on first use
local loaded, packer = pcall(require, 'packer')
if not loaded then return end

-- compile plugin configuration (i.e., this file) when changed
local packer_user_config = vim.api.nvim_create_augroup('packer_user_config', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
    group = packer_user_config,
    pattern = 'plugins.lua',
    callback = function(props)
        vim.cmd.source(props.file)
        packer.compile()
    end
})

return packer.startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- dependency
    use 'nvim-lua/plenary.nvim'

    -- dependency
    use 'neovim/nvim-lspconfig'

    -- done
    use {
        -- 'p00f/clangd_extensions.nvim',
        'https://git.sr.ht/~p00f/clangd_extensions.nvim',
        requires = 'neovim/nvim-lspconfig'
    }

    -- done
    use {
        'simrat39/rust-tools.nvim',
        requires = 'neovim/nvim-lspconfig'
    }

    -- done
    use {
        'https://git.sr.ht/~p00f/godbolt.nvim',
        config = function()
            local status, mod = pcall(require, 'godbolt')
            if status then
                mod.setup({
                    languages = {
                        cpp = { compiler = "g122", options = {} },
                        c = { compiler = "cg122", options = {} },
                        rust = { compiler = "r1650", options = {} },
                        -- any_additional_filetype = { compiler = ..., options = ... },
                    },
                    quickfix = {
                        enable = false,         -- whether to populate the quickfix list in case of errors
                        auto_open = false       -- whether to open the quickfix list in case of errors
                    },
                    url = "https://godbolt.org" -- can be changed to a different godbolt instance
                })
            end
        end
    }

    -- done
    use 'folke/flash.nvim'

    -- done
    use 'mfussenegger/nvim-lint'

    -- done
    use {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        config = function()
            local status, mod = pcall(require, 'lsp_lines')
            if status then mod.setup() end
        end,
    }

    -- done
    use {
        'nvim-telescope/telescope.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            local status, mod = pcall(require, 'telescope')
            if status then mod.setup() end
        end
    }

    -- done
    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        requires = 'nvim-telescope/telescope.nvim',
        run = 'make',
        config = function()
            local status, mod = pcall(require, 'telescope')
            if status then mod.load_extension('fzf') end
        end
    }

    -- done
    use {
        'kylechui/nvim-surround',
        config = function()
            local status, mod = pcall(require, 'nvim-surround')
            if status then mod.setup() end
        end
    }

    use {
        'ldelossa/nvim-ide',
        disable = true,
        config = function()
            local status, mod = pcall(require, 'ide')
            if status then
                mod.setup({
                    icon_set = "codicon",
                    panel_groups = {
                        explorer = { require('ide.components.outline').Name }
                    },
                    panel_sizes = {
                        left = 60,
                        right = 30,
                        bottom = 15
                    }
                })
            end
        end
    }

    use {
        'ldelossa/litee.nvim',
        disable = true,
        config = function()
            local status, mod = pcall(require, 'litee.lib')
            if status then
                mod.setup({
                    tree = { icon_set = 'codicons', indent_guides = false },
                    panel = { panel_size = 50 }
                })
            end
        end
    }

    use {
        'ldelossa/litee-symboltree.nvim',
        disable = true,
        requires = 'ldelossa/litee.nvim',
        config = function()
            local status, mod = pcall(require, 'litee.symboltree')
            if status then
                mod.setup({ icon_set = 'codicons', on_open = 'panel' })
            end
        end
    }

    use {
        'ldelossa/litee-calltree.nvim',
        disable = true,
        requires = 'ldelossa/litee.nvim',
        config = function()
            local status, mod = pcall(require, 'litee.calltree')
            if status then
                mod.setup({ icon_set = 'codicons', on_open = 'panel' })
            end
        end
    }

    use 'L3MON4D3/LuaSnip'

    use 'hrsh7th/nvim-cmp'

    use { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp', requires = 'hrsh7th/nvim-cmp' }

    use { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp', requires = 'hrsh7th/nvim-cmp' }

    use { 'hrsh7th/cmp-nvim-lsp', requires = 'hrsh7th/nvim-cmp' }

    use { 'hrsh7th/cmp-buffer', after = 'nvim-cmp', requires = 'hrsh7th/nvim-cmp' }
    use { 'hrsh7th/cmp-path', after = 'nvim-cmp', requires = 'hrsh7th/nvim-cmp' }
    use { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp', requires = 'hrsh7th/nvim-cmp' }
    use { 'hrsh7th/cmp-nvim-lsp-signature-help', requires = 'hrsh7th/nvim-cmp' }


    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    use {
        'nvim-treesitter/nvim-treesitter-textobjects',
        requires = 'nvim-treesitter/nvim-treesitter'
    }

    use {
        'nvim-treesitter/nvim-treesitter-context',
        requires = 'nvim-treesitter/nvim-treesitter',
        config = function()
            local status, mod = pcall(require, 'treesitter-context')
            if status then mod.setup() end
        end
    }

    use {
        'nvim-treesitter/playground',
        requires = 'nvim-treesitter/nvim-treesitter'
    }

    use {
        'ckolkey/ts-node-action',
        requires = 'nvim-treesitter',
        config = function()
            local status, mod = pcall(require, 'ts-node-action')
            if not status then return end
            mod.setup()
            vim.keymap.set('n', "<C-k>", mod.node_action)
        end
    }

    use {
        'HiPhish/nvim-ts-rainbow2',
        requires = 'nvim-treesitter'
    }

    use {
        'danymat/neogen',
        requires = 'nvim-treesitter/nvim-treesitter',
        config = function()
            local status, mod = pcall(require, 'neogen')
            if status then mod.setup({ enabled = true }) end
        end
    }

    use {
        "Badhi/nvim-treesitter-cpp-tools",
        disable = true,
        requires = "nvim-treesitter/nvim-treesitter"
    }

    use 'mfussenegger/nvim-dap'

    use {
        'rcarriga/nvim-dap-ui',
        requires = 'mfussenegger/nvim-dap',
        config = function()
            local status, mod = pcall(require, 'dapui')
            if status then
                mod.setup({
                    layouts = {
                        {
                            elements = {
                                "scopes",
                                "breakpoints",
                                "stacks",
                                'watches'
                            },
                            size = 80,
                            position = 'left'
                        },
                        {
                            elements = {
                                'repl',
                                'console'
                            },
                            size = 0.25, -- 25% of total lines
                            position = 'bottom'
                        }
                    },
                    controls = {
                        -- Requires Neovim nightly (or 0.8 when released)
                        enabled = true,
                        -- Display controls in this element
                        element = "repl",
                        --[[ icons = {
                            pause = " ",
                            play = " ",
                            step_into = " ",
                            step_over = " ",
                            step_out = " ",
                            step_back = " ",
                            run_last = " ",
                            terminate = " ",
                        }, ]]
                    },
                })

                local dap = require('dap')

                dap.listeners.after.event_initialized['dapui_config'] = function(_, _) mod.open({ reset = true }) end
                dap.listeners.before.event_terminated['dapui_config'] = function(_, _) mod.close({}) end
                dap.listeners.before.event_exited['dapui_config'] = function(_, _) mod.close({}) end
            end
        end
    }

    use {
        'theHamsta/nvim-dap-virtual-text',
        requires = 'mfussenegger/nvim-dap',
        config = function()
            local status, mod = pcall(require, 'nvim-dap-virtual-text')
            if status then
                mod.setup({
                    -- TODO: use lsp formatting width or maybe editorconfig settings and then textwidth as fallback
                    virt_text_win_col = (vim.bo.textwidth > 0 and vim.bo.textwidth or 80) + 5
                })
            end
        end
    }

    -- done
    use {
        'andrewferrier/debugprint.nvim',
        config = function()
            local status, mod = pcall(require, 'debugprint')
            if status then mod.setup() end
        end,
    }

    use {
        'NeogitOrg/neogit',
        disable = true,
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            local status, mod = pcall(require, 'neogit')
            if status then mod.setup() end
        end
    }

    use {
        'lewis6991/gitsigns.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            local status, mod = pcall(require, 'gitsigns')
            if status then mod.setup() end
        end
    }

    -- done
    use {
        'numToStr/Comment.nvim',
        config = function()
            local status, mod = pcall(require, 'Comment')
            if status then mod.setup({ ignore = '^$' }) end
        end
    }

    use {
        'folke/todo-comments.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            local status, mod = pcall(require, 'todo-comments')
            if status then
                mod.setup({
                    keywords = {
                        FIX = { icon = ' ' },
                        TODO = { icon = ' ' },
                        HACK = { icon = ' ' }, -- TODO: find a better icon for HACK
                        PERF = { icon = ' ' },
                        NOTE = { icon = ' ' },
                        -- custom keywords
                        SEE = { icon = ' ', color = 'info' }
                    }

                    -- highlight = {before = 'fg'}
                })
            end
        end
    }

    -- done
    use {
        'Bekaboo/dropbar.nvim',
        config = function()
            local status, mod = pcall(require, 'dropbar')
            if status then
                mod.setup({
                    icons = {
                        kinds = {
                            symbols = {
                                Account        = '  ',
                                Array          = '  ',
                                Bookmark       = '  ',
                                Boolean        = '  ',
                                Calendar       = '  ',
                                Check          = '  ',
                                CheckAll       = '  ',
                                Circle         = '  ',
                                CircleFilled   = '  ',
                                CirclePause    = '  ',
                                CircleSlash    = '  ',
                                CircleStop     = '  ',
                                Class          = '  ',
                                Collapsed      = '  ',
                                Color          = '  ',
                                Comment        = '  ',
                                CommentExclaim = '  ',
                                Constant       = '  ',
                                Constructor    = '  ',
                                DiffAdded      = '  ',
                                Enum           = '  ',
                                EnumMember     = '  ',
                                Event          = '  ',
                                Expanded       = '  ',
                                Field          = '  ',
                                File           = '  ',
                                Folder         = '  ',
                                Function       = '  ',
                                GitBranch      = '  ',
                                GitCommit      = '  ',
                                GitCompare     = '  ',
                                GitIssue       = '  ',
                                GitMerge       = '  ',
                                GitPullRequest = '  ',
                                GitRepo        = '  ',
                                History        = '  ',
                                IndentGuide    = '⎸  ',
                                Info           = '  ',
                                Interface      = '  ',
                                Key            = '  ',
                                Keyword        = '  ',
                                Method         = '  ',
                                Module         = '  ',
                                MultiComment   = '  ',
                                Namespace      = '  ',
                                Notebook       = '  ',
                                Notification   = '  ',
                                Null           = '  ',
                                Number         = '  ',
                                Object         = '  ',
                                Operator       = '  ',
                                Package        = '  ',
                                Pass           = '  ',
                                PassFilled     = '  ',
                                Pencil         = '  ',
                                Property       = '  ',
                                Reference      = '  ',
                                RequestChanges = '  ',
                                Separator      = '•  ',
                                Snippet        = '  ',
                                Space          = '   ',
                                String         = '  ',
                                Struct         = '  ',
                                Sync           = '  ',
                                Text           = '  ',
                                TypeParameter  = '  ',
                                Unit           = '  ',
                                Value          = '  ',
                                Variable       = '  ',
                            }
                        },
                        ui = {
                            bar = {
                                separator = '  '
                            }
                        }
                    }
                })
            end
        end
    }

    -- done
    use {
        'nvim-lualine/lualine.nvim',
        config = function()
            local status, mod = pcall(require, 'lualine')
            if status then
                mod.setup({
                    options = {
                        component_separators = '',
                        section_separators = '',
                        -- disabled_filetypes = { 'help' },
                        globalstatus = true
                    },

                    sections = {
                        lualine_b = {
                            { 'branch', icon = ' ' },
                            { 'diff',   colored = false }, {
                            'diagnostics',
                            sources = { 'nvim_diagnostic' },
                            sections = { 'error', 'warn' },
                            symbols = { error = '  ', warn = '  ' }
                            -- colored = false
                        }
                        },

                        lualine_x = {
                            'encoding',
                            {
                                'fileformat',
                                symbols = {
                                    unix = ' ',
                                    dos = ' ',
                                    mac = ' '
                                }
                            }, 'filetype'
                        }
                    },

                    extensions = { 'quickfix', 'nvim-dap-ui' }
                })
            end
        end
    }

    use {
        'folke/which-key.nvim',
        disable = true,
        config = function()
            local status, mod = pcall(require, 'which-key')
            if status then mod.setup() end
        end
    }

    -- done
    use {
        'rose-pine/neovim',
        as = 'rose-pine',
        config = function()
            vim.opt.termguicolors = true
            vim.cmd.colorscheme('rose-pine')
        end,
        cond = function() return vim.env.COLORTERM == 'truecolor' end
    }

    if PACKER_BOOTSTRAP then require('packer').sync() end
end)
