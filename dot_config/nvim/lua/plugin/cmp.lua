-- local has_words_before = function()
--     local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--     return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
-- end

return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp", -- already required for "capabilities" in lsp_config options; likely not needed here
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp-signature-help", -- can we do better? https://github.com/hrsh7th/cmp-nvim-lsp-signature-help

        -- used for cmdline (and search) completion
        "hrsh7th/cmp-cmdline"
    },
    opts = function()
        local cmp = require("cmp")
        -- local luasnip = require("luasnip")
        return {
            -- snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
            snippet = { expand = function(args) vim.snippet.expand(args.body) end },
            window = {
                completion    = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered()
            },
            -- don't automatically select the first completion entry when the menu pops
            preselect = cmp.PreselectMode.None,
            -- cmp.mapping.xxx differes from cmp.xxx in that it returns a function that calls cmp.xxx and then a default
            -- fallback (the current mapping) in the case cmp.xxx doesn't succeed, or if some other condition is false.
            -- SEE: https://github.com/hrsh7th/nvim-cmp/blob/c4e491a87eeacf0408902c32f031d802c7eafce8/lua/cmp/config/mapping.lua
            mapping = {
                ["<C-B>"]     = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                ["<C-F>"]     = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                ["<C-Space>"] = cmp.mapping(cmp.mapping.complete({ reason = cmp.ContextReason.manual }), { "i", "c" }),
                -- NOTE: `select = false` means that if no completion item is slected then don't use the first one
                ["<CR>"]      = cmp.mapping.confirm({ select = false }),
                ["<C-G>"]     = cmp.mapping({
                    -- TODO: there are many insert mode mappings that are prefixed with CTRL-G, thus need to wait for timeout
                    i = cmp.mapping.abort(),
                    -- TODO: overrides command mode mapping for moving cursor between searches (when incsearch is on)
                    c = cmp.mapping.close()
                }),
                ["<C-N>"]     = cmp.config.disable,
                ["<C-P>"]     = cmp.config.disable,
                ["<Tab>"]     = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                    elseif vim.snippet.jumpable(1) then
                        vim.snippet.jump(1)
                        -- elseif has_words_before() then
                        --     cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"]   = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                    elseif vim.snippet.jumpable(-1) then
                        vim.snippet.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" })
            },
            -- TODO(michael): look into ordering that is desirable
            -- NOTE: cmp.config.sources adds a group index according to a sources index in the outer list
            -- SEE: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/sources.lua
            sources = cmp.config.sources(
                { -- 1
                    { name = "nvim_lsp" },
                },
                { -- 2
                    { name = "buffer" },
                    { name = "path" }
                },
                { -- 3
                    { name = "nvim_lsp_signature_help" },
                }
            ),
            formatting = {
                format = function(_, vim_item)
                    local icons = require("user.ui.icon").codicons
                    vim_item.kind = icons[vim_item.kind] .. "  " .. vim_item.kind
                    -- vin_item.kind = "%s %s".format
                    return vim_item
                end
            },
            -- disable cmp autocomplete in prompts and comments (can still trigger manually)
            enabled = function()
                if vim.bo.buftype == "prompt" then return false end

                local context = require("cmp.config.context")
                return not (context.in_treesitter_capture("comment") or
                    context.in_syntax_group("Comment"))
            end,
        }
    end,
    config = function(_, opts)
        local cmp = require("cmp")
        cmp.setup(opts)
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" }
            },
            -- always enable for search (i.e., overrides settings above which would disable cmp when search is invoked
            -- and the cursor is in a comment)
            -- TODO: look into why this doesn't seem to work for forward search ('/')
            enable = true
        })
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources(
                { -- 1
                    { name = "path" }
                },
                { -- 2
                    { name = "cmdline" }
                }
            ),
            -- always enable for commandline
            enabled = true
        })
    end,
    event = { "InsertEnter", "CmdlineEnter" }
}
