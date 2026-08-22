return {
  "folke/snacks.nvim",
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("custom-startup", { clear = true }),
      once = true,
      nested = true,
      callback = require("custom.safe").config(function()
        require("custom.startup").setup()
      end),
    })
  end,
  opts = {
    dashboard = {
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
  },
}
