-- TODO: look into vim.g.markdown_fenced_languages and vim.g.markdown_recommended_style

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

---@diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("user.options")
-- require keymaps first to ensure that leader key is set
require("user.keymap")
require("user.diagnostic")

require("lazy").setup({
    spec = {
        { import = "lazyspec" },
        { import = "plugin" }
    }
})

local lsp = require("user.lsp")

require("lspconfig").lua_ls.setup(lsp.config.lua_ls)

-- NOTE(from clangd_extensions.nvim doc): Set up clangd via lspconfig/vim.lsp.start, as usual. You don't need to call
-- require("clangd_extensions").setup if you like the defaults:
require("lspconfig").clangd.setup(lsp.config.clangd)

-- local function input_args()
--     require("dap").run(vim.tbl_extend("keep", require("dap").configurations.c[1], { args = { "-d" } }))
-- end

vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("auto_resize_windows", { clear = true }),
    pattern = "*",
    callback = function() vim.cmd.wincmd({ args = { "=" } }) end,
    desc = "Adjust vim window size on application resize"
})

-- global option

-- NOTE: only affects builtin completion (:help cmp-config.preselect for cmp)

--[[ Use a menu to show completion results (menu), even if there is only one
completion result (menuone). Do not automatically select the first match
(noselect). ]]
vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.keymap.set("i", "<C-N>", "<NOP>", { silent = true })
vim.keymap.set("i", "<C-P>", "<NOP>", { silent = true })

vim.keymap.set("n", "<Leader>fb",
    function()
        require("telescope.builtin").buffers(
            require("telescope.themes").get_dropdown({})
        )
    end,
    { silent = true }
)

local ts = require("nvim-treesitter.configs")
ts.setup({
    ensure_installed = { "c", "comment", "cpp", "lua", "python", "query", "rust" },

    highlight = { enable = true, additional_vim_regex_highlighting = false },

    textobjects = {
        enable = true,

        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["ak"] = "@comment.outer"
            }
        },

        swap = {
            enable = true,
            swap_next = { ["g>>"] = "@parameter.inner" },
            swap_previous = { ["g<<"] = "@parameter.inner" }
        }
    },
})

local wininput = function(opts, on_confirm, win_opts)
    -- create a "prompt" buffer that will be deleted once focus is lost
    local buf = vim.api.nvim_create_buf(false, false)
    vim.bo[buf].buftype = "prompt"
    vim.bo[buf].bufhidden = "wipe"

    local prompt = opts.prompt or ""
    local default_text = opts.default or ""

    -- defer the on_confirm callback so that it is
    -- executed after the prompt window is closed
    local deferred_callback = function(input)
        vim.defer_fn(function()
            on_confirm(input)
        end, 10)
    end

    -- set prompt and callback (CR) for prompt buffer
    vim.fn.prompt_setprompt(buf, prompt)

    vim.fn.prompt_setcallback(buf, deferred_callback)

    vim.fn.prompt_setinterrupt(buf, function()
        vim.cmd.stopinsert()
        vim.api.nvim_win_close(0, true)
    end)

    -- set some keymaps: CR confirm and exit, ESC in normal mode to abort
    vim.keymap.set({ "i", "n" }, "<CR>", "<CR><Esc>:close!<CR>:stopinsert<CR>", {
        silent = true, buffer = buf
    })
    vim.keymap.set("n", "<Esc>", "<Cmd>close!<CR>", {
        silent = true, buffer = buf
    })

    -- end, { expr = true, silent = true, buffer = buf })

    local default_win_opts = {
        relative = "editor",
        row = vim.o.lines / 2 - 1,
        col = vim.o.columns / 2 - 25,
        width = 50,
        height = 1,
        focusable = true,
        style = "minimal",
        border = "rounded",
    }

    win_opts = vim.tbl_deep_extend("force", default_win_opts, win_opts)

    -- adjust window width so that there is always space
    -- for prompt + default text plus a little bit
    win_opts.width = #default_text + #prompt + 5 < win_opts.width and win_opts.width or #default_text + #prompt + 5

    -- open the floating window pointing to our buffer and show the prompt
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.api.nvim_set_option_value("winhighlight", "Search:None", { scope = "local", win = win })

    vim.cmd.startinsert()

    -- set the default text (needs to be deferred after the prompt is drawn)
    vim.defer_fn(function()
        -- Sometimes errors on 3rd parameter (start_col) being invalid
        -- SEE: :help nvim_buf_set_text
        vim.api.nvim_buf_set_text(buf, 0, #prompt, 0, #prompt, { default_text })
        vim.cmd.startinsert({ bang = true }) -- bang: go to end of line
    end, 5)
end

-- override vim.ui.input ( telescope rename/create, lsp rename, etc )
vim.ui.input = function(opts, on_confirm)
    vim.validate({ on_confirm = { on_confirm, "function", false } })
    -- intercept opts and on_confirm,
    -- check buffer options, filetype, etc and set window options accordingly.
    wininput(opts, on_confirm, { border = "rounded", relative = "cursor", row = 1, col = 0, width = 0 })
end

--[[ local function hl_search(blinktime)
    local ns = vim.api.nvim_create_namespace("search")
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

    local search_pat = "\\c\\%#" .. vim.fn.getreg("/")
    local m = vim.fn.matchadd("IncSearch", search_pat)
    vim.cmd("redraw")
    vim.cmd("sleep " .. blinktime * 1000 .. "m")

    local sc = vim.fn.searchcount()
    vim.api.nvim_buf_set_extmark(0, ns, vim.api.nvim_win_get_cursor(0)[1] - 1, 0, {
        virt_text = { { "[" .. sc.current .. "/" .. sc.total .. "]", "Comment" } },
        virt_text_pos = "eol",
    })

    vim.fn.matchdelete(m)
    vim.cmd("redraw")
end

vim.keymap.set("n", "n", function()
    vim.cmd("normal! nzz")
    hl_search(0.3)
end)

vim.keymap.set("n", "N", function()
    vim.cmd("normal! Nzz")
    hl_search(0.3)
end) ]]
