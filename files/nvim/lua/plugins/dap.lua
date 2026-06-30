vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/theHamsta/nvim-dap-virtual-text",
})

local packageCwd = function()
  local file = vim.api.nvim_buf_get_name(0);
  print(file);

  if file:find("/packages/") or file:find("/apis/") then
    -- Matches "some/path/" in "some/path/src/"
    local srcMatch = file:match("(.*/[^/]+/)src")

    print(srcMatch);

    if srcMatch then
      return srcMatch
    end

    local testMatch = file:match("(.*/[^/]+/)test")

    if testMatch then
      return testMatch
    end
  end

  return vim.fn.getcwd()
end

local _dap_initialized = false
local function init_dap()
  local dap = require("dap")
  local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
  local currentPackageCwd = packageCwd()
  print(currentPackageCwd)

  if _dap_initialized then
    for _, ft in ipairs(js_filetypes) do
      dap.configurations[ft][1].cwd = currentPackageCwd;
      dap.configurations[ft][2].cwd = currentPackageCwd;
      dap.configurations[ft][3].cwd = currentPackageCwd;
      dap.configurations[ft][4].cwd = currentPackageCwd;
    end

    return
  end

  _dap_initialized = true

  local dapui = require("dapui")

  -- Point to vscode-js-debug
  local js_debug_path = vim.fn.expand(
    "/Users/florian.kauder/js-debug/src/dapDebugServer.js")

  -- Setup the adapter
  dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "node",
      args = { js_debug_path, "${port}" },
    },
  }

  -- Alias "node" to "pwa-node"
  dap.adapters["node"] = function(cb, config)
    if config.type == "node" then
      config.type = "pwa-node"
    end

    local a = dap.adapters["pwa-node"]

    if type(a) == "function" then
      a(cb, config)
    else
      cb(a)
    end
  end


  -- Debug configurations for JS/TS

  for _, ft in ipairs(js_filetypes) do
    dap.configurations[ft] = {
      -- Attach to running Node.js process
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach to Node.js",
        port = 9229,
        address = "localhost",
        localRoot = vim.fn.getcwd(),
        remoteRoot = "/usr/src/app",
        cwd = currentPackageCwd,
        sourceMaps = true,
        protocol = "inspector",
      },
      -- Run package in debug mode
      {
        type = "pwa-node",
        request = "launch",
        name = "Run in debug",
        runtimeArgs = {
          "start:debug",
        },
        cwd = currentPackageCwd,
        runtimeExecutable = "pnpm",
        internalConsoleOptions = "openOnSessionStart",
        skipFiles = { "<node_internals>/**" },
        sourceMaps = true,
        protocol = "inspector",
      },
      -- Debug Mocha tests
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Mocha Tests",
        program = "${workspaceFolder}/node_modules/mocha/bin/_mocha",
        args = {
          "--require",
          "ts-node/register/transpile-only",
          "--require",
          "source-map-support/register",
          "--reporter",
          "spec",
          "--colors",
          "${workspaceFolder}/tests/unit/**/*.[tj]s",
        },
        cwd = currentPackageCwd,
        runtimeExecutable = "node",
        internalConsoleOptions = "openOnSessionStart",
        skipFiles = { "<node_internals>/**" },
        sourceMaps = true,
        protocol = "inspector",
      },
      -- Debug Jest tests
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Jest Tests",
        program = "${workspaceFolder}/node_modules/jest/bin/jest.js",
        args = { "--runInBand", "--no-cache", "--no-colors", "${relativeFile}" },
        cwd = currentPackageCwd,
        runtimeExecutable = "node",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        skipFiles = { "<node_internals>/**" },
      },
    }
  end

  -- DAP UI setup
  dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
    controls = {
      icons = {
        pause = "⏸",
        play = "▶",
        step_into = "⏎",
        step_over = "⏭",
        step_out = "⏮",
        step_back = "b",
        run_last = "▶▶",
        terminate = "⏹",
        disconnect = "⏏",
      },
    },
  })

  -- Auto-open/close UI
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open({})
  end

  -- dap.listeners.before.event_terminated["dapui_config"] = function()
  --
  --   dapui.close({})
  -- end
  --
  -- dap.listeners.before.event_exited["dapui_config"] = function()
  --   dapui.close({})
  -- end
  --
  -- dap.listeners.before.disconnect["dapui_config"] = function()
  --   dapui.close({})
  -- end

  -- Virtual text
  require("nvim-dap-virtual-text").setup()
end


-- Keymaps

-- stylua: ignore start
vim.keymap.set("n", "<leader>db", function()
  init_dap(); require("dap").toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })

vim.keymap.set("n", "<leader>dB", function()
  init_dap(); require("dap").list_breakpoints(); vim.cmd("copen")
end, { desc = "List Breakpoints" })

vim.keymap.set("n", "<leader>dc", function()
  init_dap(); require("dap").continue()
end, { desc = "Run/Continue" })

vim.keymap.set("n", "<leader>dC", function()
  init_dap(); require("dap").run_to_cursor()
end, { desc = "Run to Cursor" })

vim.keymap.set("n", "<leader>dg", function()
  init_dap(); require("dap").goto_()
end, { desc = "Go to Line (No Execute)" })

vim.keymap.set("n", "<leader>di", function()
  init_dap(); require("dap").step_into()
end, { desc = "Step Into" })

vim.keymap.set("n", "<leader>dj", function()
  init_dap(); require("dap").down()
end, { desc = "Down" })

vim.keymap.set("n", "<leader>dk", function()
  init_dap(); require("dap").up()
end, { desc = "Up" })

vim.keymap.set("n", "<leader>dl", function()
  init_dap(); require("dap").run_last()
end, { desc = "Run Last" })

vim.keymap.set("n", "<leader>do", function()
  init_dap(); require("dap").step_out()
end, { desc = "Step Out" })

vim.keymap.set("n", "<leader>dO", function()
  init_dap(); require("dap").step_over()
end, { desc = "Step Over" })

vim.keymap.set("n", "<leader>dP", function()
  init_dap(); require("dap").pause()
end, { desc = "Pause" })

vim.keymap.set("n", "<leader>dr", function()
  init_dap(); require("dap").repl.toggle()
end, { desc = "Toggle REPL" })

vim.keymap.set("n", "<leader>ds", function()
  init_dap(); require("dap").session()
end, { desc = "Session" })

vim.keymap.set("n", "<leader>dt", function()
  init_dap()
  require("dap").terminate()
  vim.defer_fn(function()
    require("dapui").close({})
  end, 100)
end, { desc = "Terminate" })

vim.keymap.set("n", "<leader>dw", function()
  init_dap(); require("dap.ui.widgets").hover()
end, { desc = "DAP Widgets" })

vim.keymap.set("n", "<leader>du", function()
  init_dap(); require("dapui").toggle({})
end, { desc = "Dap UI" })

-- stylua: ignore end
