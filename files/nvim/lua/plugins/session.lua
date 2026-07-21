vim.pack.add({
  "https://github.com/rmagatti/auto-session",
})

local session = require("auto-session")

session.setup({
  cwd_change_handling = true,
})

vim.keymap.set("n", "<leader>@@", "<Cmd>AutoSession search<CR>", { desc = "Select session" })
