vim.pack.add({
  "https://github.com/folke/sidekick.nvim",
})

vim.keymap.set({ "n", "t", "i", "x" }, "<leader>fai", function()
  require("sidekick.cli").toggle()
end, { desc = "AI CLI" })
