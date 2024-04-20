local M = {}

local ret_or_eval = function(cond)
    vim.validate({ cond = { cond, { "boolean", "function" } } })
    if type(cond) == "boolean" then
        return cond
    end
    return cond
end

M.keymap_table = function(keys)
    for _, key in ipairs(keys) do
        if key.cond == nil or ret_or_eval(key.cond) then
            vim.keymap.set(
                key.mode,
                key.lhs,
                key.rhs,
                vim.tbl_extend("force", key.opts, { desc = key.desc })
            )
        end
    end
end

M.map_exec = function(cmd)
    return function()
        vim.cmd.execute({
            args = { string.format("'%s'", cmd) }
        })
    end
end

M.map_counted_exec = function(cmd)
    return M.map_exec(string.format("%d%s", vim.v.count1, cmd))
end

return M
