vim.pack.add({
  "https://github.com/folke/tokyonight.nvim"
})

require("tokyonight").setup({

  style = "night",
  transparent = true,
  on_colors = function(colors)
    colors.bg_visual = "#485497"
  end
})

vim.cmd("colorscheme tokyonight")
