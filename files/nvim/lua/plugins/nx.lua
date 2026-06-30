vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/yardnsm/nx-console.nvim",
})

local nx = require("nx-console")

nx.setup({
  picker = "snacks",
})

local function run_target(target)
  local config = require("nx-console.config")
  local cmd

  if type(target) == "string" then
    -- String format: "project:target:configuration"
    cmd = "pnpm nx run " .. target
  else
    -- Structured format: { project, target, configuration }
    local nx_id_builder = require("nx-console.util.nx-id-builder")
    local id = nx_id_builder.build_target_id(target.project, target.target, target.configuration)
    cmd = "pnpm nx run " .. id
  end

  config.options.command_runner(cmd)
end

require("nx-console.actions").run_target = run_target;

vim.keymap.set("n", "<leader>nxp", function()
  nx.pickers.projects()
end, { desc = "NX Projects" })

vim.keymap.set("n", "<leader>nxt", function()
  nx.pickers.targets_current()
end, { desc = "NX Targets current" })

vim.keymap.set("n", "<leader>nxT", function()
  nx.pickers.targets()
end, { desc = "NX Targets" })

vim.keymap.set("n", "<leader>nxg", function()
  nx.pickers.generators()
end, { desc = "NX Generators" })
