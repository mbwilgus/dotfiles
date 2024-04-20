local diagnostic = vim.diagnostic

local M = {}

M.signs = {
    { name = "DiagnosticSignError", text = " ", texthl = "DiagnosticSignError", linehl = "", numhl = "" },
    { name = "DiagnosticSignWarn", text = " ", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" },
    { name = "DiagnosticSignInfo", text = " ", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" },
    { name = "DiagnosticSignHint", text = " ", texthl = "DiagnosticSignHint", linehl = "", numhl = "" },
}

vim.fn.sign_define(M.signs)

local ns_squashed_diagnostics = vim.api.nvim_create_namespace("squashed_diagnostics")
local orig_signs_handler = diagnostic.handlers.signs

diagnostic.handlers.signs = {
    show = function(_, bufnr, _, opts)
        local diagnostics = diagnostic.get(bufnr)

        local line_has = vim.defaulttable(
            function()
                return {
                    [diagnostic.severity.INFO]  = false,
                    [diagnostic.severity.WARN]  = false,
                    [diagnostic.severity.HINT]  = false,
                    [diagnostic.severity.ERROR] = false,
                }
            end)

        local signs = {}

        for _, diag in pairs(diagnostics) do
            if not line_has[diag.lnum][diag.severity] then
                line_has[diag.lnum][diag.severity] = true
                table.insert(signs, diag)
            end
        end

        orig_signs_handler.show(ns_squashed_diagnostics, bufnr, signs, opts)
    end,

    hide = function(_, bufnr)
        orig_signs_handler.hide(ns_squashed_diagnostics, bufnr);
    end
}

local mode = "n"
local opts = { silent = true }

local keys = {
    {
        mode = mode,
        lhs  = "[d",
        rhs  = diagnostic.goto_prev,
        desc = "Goto previous diagnostic",
        opts = opts
    },
    {
        mode = mode,
        lhs  = "]d",
        rhs  = diagnostic.goto_next,
        desc = "Goto next diagnostic",
        opts = opts
    },
    {
        mode = mode,
        lhs  = "[e",
        rhs  = function() diagnostic.goto_prev({ severity = diagnostic.severity.ERROR }) end,
        desc = "Goto previous error",
        opts = opts
    },
    {
        mode = mode,
        lhs  = "]e",
        rhs  = function() diagnostic.goto_next({ severity = diagnostic.severity.ERROR }) end,
        desc = "Goto next error",
        opts = opts
    },
}

require("user.helper").keymap_table(keys)

return M
