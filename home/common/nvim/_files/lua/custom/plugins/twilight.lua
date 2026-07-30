return {
  "folke/twilight.nvim",
  cmd = "Twilight",
  opts = {
    dimming = {
      alpha = 0.5,
      color = { "Normal", "#ffffff" },
      term_bg = "#000000",
      inactive = false,
    },
    context = 7,
    treesitter = true,

    expand = {
      "function",
      "method",
      "table",
      "if_statement",
    },
    exclude = {},
  },
}
