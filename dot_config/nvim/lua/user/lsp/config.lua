local attach = require("user.lsp.attach")

local M = {}

M.clangd = {
    on_attach = function(client, bufnr)
        local opts = { silent = true, buffer = bufnr }
        local clangd_keys = {
            {
                mode = "n",
                lhs  = "<Leader>s",
                rhs  = "<Cmd>ClangdSwitchSourceHeader<CR>",
                desc = "Switch between definition and implementation files",
                opts = opts
            },
            {
                mode = "n",
                lhs  = "<Leader>h",
                rhs  = "<Cmd>ClangdToggleInlayHints<CR>",
                desc = "Toggle inlay hints",
                opts = opts
            }
        }
        require("user.helper").keymap_table(clangd_keys)

        require("clangd_extensions.inlay_hints").setup_autocmd()
        require("clangd_extensions.inlay_hints").set_inlay_hints()

        vim.keymap.set("n", "<Leader>i", function()
            -- local bufnr = vim.api.nvim_get_current_buf()
            local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })
            if #clients > 0 then
                vim.lsp.buf_request(bufnr, "textDocument/inlayHint", {
                        textDocument = vim.lsp.util.make_text_document_params(),
                        range = {
                            start = {
                                line = 0,
                                character = 0
                            },
                            ["end"] = {
                                line = vim.api.nvim_buf_line_count(bufnr),
                                character = 0,
                            }

                        }
                    },
                    function(err, result, ctx)
                        if err then
                            vim.print(err.message)
                            return
                        end

                        if ctx.bufnr ~= bufnr then return end
                        vim.print(result)
                    end)
            end
        end)

        attach.format(client, bufnr)
        attach.keys(client, bufnr)
        attach.ui(client, bufnr)
    end,
    capabilities = require("cmp_nvim_lsp").default_capabilities()
}

M.lua_ls = {
    on_attach = function(client, bufnr)
        attach.format(client, bufnr)
        attach.keys(client, bufnr)
        attach.ui(client, bufnr)
    end,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
}

M.rust_analyzer = {
    on_attach = function(client, bufnr)
        attach.format(client, bufnr)
        attach.keys(client, bufnr)
        attach.ui(client, bufnr)
    end,
    capabilities = require("cmp_nvim_lsp").default_capabilities()
}

return M
