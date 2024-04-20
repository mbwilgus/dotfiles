M = {}

M.signs = {
    breakpoint = { name = "DapBreakpoint", text = " ", texthl = "", linehl = "", numhl = "" },
    stopped    = { name = "DapStopped", text = " ", texthl = "", linehl = "", numhl = "" }
}

-- SEE: h: dap.txt

-- description of DAP components

-- DAP-Client ----- Debug Adapter ------- Debugger ------ Debugee
-- (nvim-dap)  |   (per language)  |   (per language)    (your app)
--             |                   |
--             |        Implementation specific communication
--             |        Debug adapter and debugger could be the same process
--             |
--      Communication via the Debug Adapter Protocol

-- table (index is arbitrary name) describing a debug adapter, a component that communicates to the actual debugger
M.adapters = {}

-- table (index is filetype) describing how to launch/attach to application to debug
-- NOTE: configurations are looked up in the table when `dap-continue` is invoked
-- NOTE: a defined adapter is part of a cofiguration definition (referred to by its name in the adapters table)
M.configurations = {}

M.adapters.cppdbg = {
    id = "cppdbg",
    type = "executable",
    -- TODO: make more portable (e.g., $HOME or $XDG_...)
    command = vim.env.HOME .. "/.local/dap/vscode-cpptools/extension/debugAdapters/bin/OpenDebugAD7"
}

local input_path_to_executable = function()
    return vim.fn.input({ prompt = "Path to executable: ", default = vim.fn.getcwd() .. "/", completion = "file" })
end

local gdb_setup = {
    {
        text = "-enable-pretty-printing",
        description = "enable pretty printing",
        ignoreFailures = false
    }
}

M.configurations.cpp = {
    {
        type          = "cppdbg",
        request       = "launch",
        name          = "Launch file",
        cwd           = "${workspaceFolder}",
        program       = input_path_to_executable,
        stopOnEntry   = true,
        setupCommands = gdb_setup
    },
    {
        type                    = "cppdbg",
        request                 = "launch",
        name                    = "Attach to gdbserver :1234",
        cwd                     = "${workspaceFolder}",
        program                 = input_path_to_executable,
        stopOnEntry             = true,
        setupCommands           = gdb_setup,

        -- SEE: https://code.visualstudio.com/docs/cpp/launch-json-reference#_customizing-gdb-or-lldb
        MIMode                  = "gdb",
        miDebuggerPath          = "/usr/bin/gdb",

        -- SEE: https://code.visualstudio.com/docs/cpp/launch-json-reference#_remote-debugging-or-debugging-with-a-local-debugger-server
        miDebuggerServerAddress = "localhost:1234"
    }
}

M.configurations.c = M.configurations.cpp
M.configurations.rust = M.configurations.cpp

M.configure = {}

M.configure.ui = function(dap, dapui)
    dap.listeners.before.attach.dapui_config           = function(_, _) dapui.open({ reset = true }) end
    dap.listeners.before.launch.dapui_config           = function(_, _) dapui.open({ reset = true }) end
    dap.listeners.before.event_terminated.dapui_config = function(_, _) dapui.close({}) end
    dap.listeners.before.event_exited.dapui_config     = function(_, _) dapui.close({}) end
end

return M
