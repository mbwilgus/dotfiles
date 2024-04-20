local function get_hl(name) return vim.api.nvim_get_hl(0, { name = name }) end

-- hl-groups can have any name
vim.api.nvim_set_hl(0, "SymbolUsageRounding", { fg = get_hl("CursorLine").bg, italic = true })
vim.api.nvim_set_hl(0, "SymbolUsageContent", { bg = get_hl("CursorLine").bg, fg = get_hl("Comment").fg, italic = true })
vim.api.nvim_set_hl(0, "SymbolUsageRef", { fg = get_hl("Function").fg, bg = get_hl("CursorLine").bg, italic = true })
vim.api.nvim_set_hl(0, "SymbolUsageDef", { fg = get_hl("Type").fg, bg = get_hl("CursorLine").bg, italic = true })
vim.api.nvim_set_hl(0, "SymbolUsageImpl", { fg = get_hl("@keyword").fg, bg = get_hl("CursorLine").bg, italic = true })

local text_format = function(symbol)
    local res = {}

    local round_start = { "", "SymbolUsageRounding" }
    local round_end = { "", "SymbolUsageRounding" }

    local make_badge = function(count, icon, text, hl)
        text  = count <= 1 and text or text .. "s"
        count = count == 0 and "no" or tostring(count)

        table.insert(res, round_start)
        table.insert(res, { icon, hl })
        table.insert(res, { (" %s %s"):format(count, text), "SymbolUsageContent" })
        table.insert(res, round_end)
    end

    local add_space_if = function(cond)
        if cond then
            table.insert(res, { " ", "NonText" })
        end
    end


    if symbol.references then
        make_badge(symbol.references, "󰌹 ", "usage", "SymbolUsageRef")
    end

    if symbol.definition then
        add_space_if(#res > 0)
        make_badge(symbol.definition, "󰳽 ", "def", "SymbolUsageDef")
    end

    if symbol.implementation then
        add_space_if(#res > 0)
        make_badge(symbol.implementation, "󰡱 ", "impl", "SymbolUsageImpl")
    end

    return res
end

return {
    "Wansmer/symbol-usage.nvim",
    opts = {
        text_format = text_format,
        -- definition = { enabled = true },
        -- implementation = { enabled = true },
    },
    config = true,
    event = "LspAttach", -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
}
