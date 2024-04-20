local spec = {
    -- LSP
    {
        url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        enabled = false,
        config = function(_)
            vim.diagnostics.config({ virtual_text = false })
        end,
        event = "VeryLazy"
    },

    -- dap
    {
        "mfussenegger/nvim-dap",
        config = function(_, _)
            local dap = require("dap")

            ---@diagnostic disable-next-line: different-requires
            local dapconf = require("user.dap")

            dap.adapters = dapconf.adapters
            dap.configurations = dapconf.configurations
            vim.fn.sign_define(vim.tbl_values(dapconf.signs))
        end,
        keys = {
            {
                "<F5>",
                mode = "n",
                function() require("dap").continue() end,
                desc = "Run a debug configuration or continue execution of the currently running configuration"
            },
            {
                "<F6>",
                mode = "n",
                function() require("dap").run_to_cursor() end,
                desc = "Contunue exectution and break at the current cursor location"
            },
            {
                "<F9>",
                mode = "n",
                function() require("dap").toggle_breakpoint() end,
                desc = "Creates or removes a breakpoint at the current line"
            },
            {
                "<F10>",
                mode = "n",
                function() require("dap").step_over() end,
                desc = "Continue execution for one step (usually a statement)"
            },
            {
                "<F11>",
                mode = "n",
                function() require("dap").step_into({ askForTargets = true }) end,
                desc = "Continue exectuion into a call if possible (behaves like step over if not)"
            },
            {
                -- "<S-F11>",
                "<F23>", -- <F23> = <S-F11>
                mode = "n",
                function() require("dap").step_out() end,
                desc = "Continue execution until the end of the frame stopping at the call site"
            }
        }
    },

    {
        "rcarriga/nvim-dap-ui",
        -- lazy = true,
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio"
        },
        opts = function()
            return {
                icons = {
                    current_frame = require("user.dap").signs.stopped.text
                }
            }
        end,
        config = function(_, opts)
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup(opts)

            ---@diagnostic disable-next-line: different-requires
            local dapconf = require("user.dap")
            dapconf.configure.ui(dap, dapui)
        end,
    },

    {
        "theHamsta/nvim-dap-virtual-text",
        -- lazy = true,
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-treesitter/nvim-treesitter",
        },
        config = true
    },

    -- diagnostics
    {
        "mfussenegger/nvim-lint",
        event = "VeryLazy"
    },

    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate"
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" }
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = true,
        event = "VeryLazy"
    },

    {
        "danymat/neogen",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = true,
        cmd = "Neogen"
    },

    -- tools
    {
        "numToStr/Comment.nvim",
        opts = { ignore = "^$" },
        event = "VeryLazy"
    },

    {
        "lewis6991/gitsigns.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = true,
        event = "VeryLazy",
        keys = {
            {
                "[h",
                mode = "n",
                function() require("gitsigns").prev_hunk() end,
                { silent = true },
                desc = "Jump to the previous hunk in the current buffer"
            },
            {
                "]h",
                mode = "n",
                function() require("gitsigns").next_hunk() end,
                { silent = true },
                desc = "Jump to the next hunk in the current buffer"
            }
        }
    },

    -- editor
    {
        "folke/flash.nvim",
        -- presumably so that /? search works off the bat?
        event = "VeryLazy",
        keys = {
            {
                "s",
                mode = { "n", "x", "o" },
                function() require("flash").jump() end,
                desc = "Flash"
            },
            -- FIX: conflicts with surround.nvim in x mode (surround visual selection)
            {
                "S",
                mode = { "n", "x", "o" },
                function() require("flash").treesitter() end,
                desc = "Flash Treesitter",
            },
            {
                "r",
                mode = "o",
                function() require("flash").remote() end,
                desc = "Remote Flash",
            },
            {
                "R",
                mode = { "x", "o" },
                function() require("flash").treesitter_search() end,
                desc = "Flash Treesitter Search",
            },
            {
                "<C-S>",
                mode = "c",
                function() require("flash").toggle() end,
                desc = "Toggle Flash Search",
            }
        }
    },

    {
        "kylechui/nvim-surround",
        config = true,
        keys = {
            {
                mode = "n",
                "ys"
            },
            -- conflicts with my cmp mapping for aborting completion <C-g>
            {
                mode = "i",
                "<C-G>s"
            },
            {
                mode = "x",
                "S",
            },
            {
                mode = "n",
                "ds"
            },
            {
                mode = "n",
                "cs"
            },
            {
                mode = "n",
                "yss"
            },
            {
                mode = "n",
                "yS"
            },
            {
                mode = "n",
                "ySS"
            },
            -- conflicts with my cmp mapping for aborting completion <C-g>
            {
                mode = "i",
                "<C-G>S"
            },
            {
                mode = "n",
                "cS"
            }
        }
    },

    -- ui
    -- TODO(michael): curate icons better
    {
        "Bekaboo/dropbar.nvim",
        opts = {
            icons = {
                kinds = {
                    use_devicons = false,
                    symbols = vim.tbl_map(
                        function(icon)
                            return string.format("%s  ", icon)
                        end,
                        require("user.ui.icon").codicons
                    )
                },
                ui = {
                    bar = {
                        separator = "  "
                    }
                }
            }
        },
        keys = {
            {
                mode = "n",
                "<leader>p",
                function() require("dropbar.api").pick() end
            }
        },
        event = "VeryLazy"
    },

    {
        "nvim-lualine/lualine.nvim",
        opts = {

            options = {
                component_separators = "",
                section_separators = "",
                -- disabled_filetypes = { "help" },
                globalstatus = true
            },

            sections = {
                lualine_b = {
                    { "branch", icon = " " },
                    { "diff", colored = false },
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        sections = { "error", "warn" },
                        symbols = { error = "  ", warn = "  " }
                        -- colored = false
                    }
                },

                lualine_x = {
                    "encoding",
                    {
                        "fileformat",
                        symbols = {
                            unix = " ",
                            dos = " ",
                            mac = " "
                        }
                    }, "filetype"
                }
            },

            extensions = { "quickfix", "nvim-dap-ui" }
        },
        event = "VeryLazy"
    }
}

return spec
