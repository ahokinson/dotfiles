return {
  "folke/which-key.nvim",
  event = "VimEnter",
  opts = {
    delay = 1,
    icons = {
      mappings = true,
      keys = {},
    },
  },
  spec = {
    { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
    { "<leader>d", group = "[D]ebug" },
    { "<leader>G", group = "[G]oto" },
    { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
    { "<leader>ps", group = "[P]arameter [S]wap" },
    { "<leader>r", group = "[R]ename" },
    { "<leader>s", group = "[S]earch" },
    { "<leader>t", group = "[T]oggle" },
    { "<leader>w", group = "[W]orkspace" },
    { "<leader>x", group = "Trouble/Diagnostics" },
  },
}
