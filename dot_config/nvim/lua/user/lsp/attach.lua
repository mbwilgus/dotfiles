local M = {}

local make_lsp_autocmd_group = function(client_id, bufnr, suffix, clear)
    clear = clear ~= nil and clear or true
    return vim.api.nvim_create_augroup(
        string.format("lsp_c_%d_b_%d_%s", client_id, bufnr, suffix),
        { clear = clear }
    )
end

M.format = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            group    = make_lsp_autocmd_group(client.id, bufnr, "format"),
            buffer   = bufnr,
            desc     = string.format("Format buffer %s on save", bufnr),
            -- TODO: why does this need to be wrapped like this?
            callback = function()
                -- SEE: h: vim.lsp.buf.format(); defaults to async = false
                vim.lsp.buf.format()
            end
            -- callback = vim.lsp.buf.format
        })

        -- SEE: h: lsp-defaults
        -- vim.bo.formatexpr = 'v:lua.vim.lsp.formatexpr'
    end
end

M.keys = function(client, bufnr)
    -- SEE: lsp-defaults
    -- set <C-X><C-O> completion capabilities (for completeness, but I don't use it)
    -- vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- SEE: lsp-defaults
    -- use <C-]> to jump to definition
    -- if capabilities.definitionProvider then
    --     vim.bo.tagfunc = 'v:lua.vim.lsp.tagfunc'
    -- end

    -- use `supports_method` (e.g., client.supports_method("textDocument/implmentation"))
    local has_capability = function(capability)
        local server_capability = client.server_capabilities[capability]
        if server_capability ~= nil and server_capability == true or type(server_capability) == "table" then
            return true
        end
        return false
    end

    vim.keymap.set("i", "<C-,>", vim.lsp.buf.signature_help, { silent = true, buffer = bufnr })

    local opts = { silent = true, buffer = bufnr }
    local keys = {
        {
            mode = "n",
            -- SEE: :help gD
            -- standard functionality is to search for GLOBAL declaration using naive a algorithm
            lhs  = "gD",
            rhs  = vim.lsp.buf.declaration,
            desc = "Jumps to the definition of the symbol under the cursor",
            opts = opts,
            cond = has_capability("declarationProvider")
        },
        {
            mode = "n",
            -- TODO(michael): look for better mnemonic
            lhs  = "gl",
            rhs  = vim.lsp.buf.implementation,
            desc = "Lists all the implementations for the symbol under the cursor",
            opts = opts,
            cond = has_capability("implementationProvider")
        },
        {
            mode = "n",
            lhs  = "gy",
            rhs  = vim.lsp.buf.type_definition,
            desc = "Jumps to the definition of the type of symbol under the cursor",
            opts = opts,
            cond = has_capability("typeDefinitionProvider")
        },
        {
            mode = "n",
            lhs  = "gS",
            rhs  = vim.lsp.buf.references,
            desc = "Lists all the refernces to the symbol under the cursor",
            opts = opts,
            cond = has_capability("referencesProvider")
        },
        {
            mode = "n",
            -- SEE: h: gO
            lhs  = "gO",
            rhs  = vim.lsp.buf.document_symbol,
            desc = "Lists all symbols in the current buffer",
            opts = opts,
            cond = has_capability("documentSymbolProvider")
        },
        -- SEE: lsp-defaults
        --[[ {
            mode = "n",
            lhs  = "K",
            rhs  = vim.lsp.buf.hover,
            desc = "Displays hover information about the symbol under the cursor",
            opts = opts,
            cond = has_capability("hoverProvider")
        }, ]]
        {
            mode = "n",
            lhs  = "<F2>",
            rhs  = vim.lsp.buf.rename,
            desc = "Renames all references to the symbol under the cursor",
            opts = opts,
            cond = has_capability("renameProvider")
        },
        {
            mode = "n",
            lhs  = "<C-.>",
            rhs  = vim.lsp.buf.code_action,
            desc = "Selects a code action available at the current cursor position",
            opts = opts,
            cond = has_capability("codeActionProvider")
        }
    }

    local keymap_table = require("user.helper").keymap_table

    keymap_table(keys)
end

-- SEE: https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/diagnostic.lua#L26
local severity_vim_to_lsp = function(severity)
    if type(severity) == "string" then
        severity = vim.diagnostic.severity[severity]
    end
    return severity
end

-- SEE: https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/diagnostic.lua#L132
local diagnostic_vim_to_lsp = function(diagnostics)
    return vim.tbl_map(function(diagnostic)
        return vim.tbl_extend("keep", {
            -- "keep" the below fields over any duplicate fields in diagnostic.user_data.lsp
            range    = {
                start   = {
                    line      = diagnostic.lnum,
                    character = diagnostic.col,
                },
                ["end"] = {
                    line      = diagnostic.end_lnum,
                    character = diagnostic.end_col,
                },
            },
            severity = severity_vim_to_lsp(diagnostic.severity),
            message  = diagnostic.message,
            source   = diagnostic.source,
            code     = diagnostic.code,
        }, diagnostic.user_data and (diagnostic.user_data.lsp or {}) or {})
    end, diagnostics)
end

local ns_code_action = vim.api.nvim_create_namespace("code_action")

-- TODO: add filtering for undesired actions (passed as param)
local code_action_listener = function(client_id, bufnr)
    local lnum            = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1] - 1

    local diagnostic_opts = {
        -- TODO(michael): requires a parameter is_pull: boolean (how do I know if it's a pull client or a push client)
        namespace = vim.lsp.diagnostic.get_namespace(client_id),
        lnum      = lnum
    }

    local diagnostics     = diagnostic_vim_to_lsp(vim.diagnostic.get(bufnr, diagnostic_opts))

    local params          = vim.lsp.util.make_range_params()
    params.context        = { diagnostics = diagnostics }

    vim.lsp.buf_request_all(0, "textDocument/codeAction", params, function(response)
        -- check if there is at least one code action available
        for _, item in pairs(response) do
            if item.result and not vim.tbl_isempty(item.result) then
                -- there is a code action... set the indicator
                -- TODO: add highlighting and make these opts configurable
                local sign_opts = {
                    end_line      = lnum,
                    id            = 1,
                    virt_text     = { { " " } },
                    virt_text_pos = "eol",
                    hl_mode       = "combine"
                }
                vim.api.nvim_buf_set_extmark(0, ns_code_action, lnum, 0, sign_opts)
                break
            end
        end
    end)
end

M.ui = function(client, bufnr)
    local capabilities = client.server_capabilities

    -- SEE: h: 'updatetime'; CurosorHold event sent every 1s (default is 4000)
    vim.opt.updatetime = 1000

    if capabilities.documentHighlightProvider then
        local group = make_lsp_autocmd_group(client.id, bufnr, "highlight")

        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group    = group,
            buffer   = bufnr,
            desc     = "Send the request to the server to resolve document highlights for the current text document position",
            callback = vim.lsp.buf.document_highlight
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinLeave" }, {
            group    = group,
            buffer   = bufnr,
            desc     = "Removes document highlights from current buffer",
            callback = vim.lsp.buf.clear_references
        })
    end

    if capabilities.codeActionProvider then
        local group = make_lsp_autocmd_group(client.id, bufnr, "code_action")

        vim.api.nvim_create_autocmd("CursorHold", {
            group    = group,
            buffer   = bufnr,
            desc     = "Display an indicator when code actions are available at the current text document position",
            callback = function() code_action_listener(client.id, bufnr) end
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "WinLeave" }, {
            group    = group,
            buffer   = bufnr,
            desc     = "Removes the indicator for code actions from the current buffer",
            callback = function() vim.api.nvim_buf_del_extmark(bufnr, ns_code_action, 1) end
        })
    end

    -- if capabilities.signatureHelpProvider then
    --     local group = make_lsp_autocmd_group(client.id, bufnr, "signature_help")

    --     vim.api.nvim_create_autocmd("CursorMovedI", {
    --         group    = group,
    --         buffer   = bufnr,
    --         desc     = "Displays signature information about the symbol under the cursor in a floating window",
    --         callback = vim.lsp.buf.signature_help
    --     })
    -- end
end

return M
