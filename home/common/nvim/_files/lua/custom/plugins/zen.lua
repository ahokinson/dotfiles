return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  keys = {
    { "<leader>z", "<cmd>ZenMode<cr>", desc = "[Z]en Mode" },
  },
  opts = {

    window = {
      backdrop = 0.9,
      width = 0.5,
      height = 1,
      options = {
        number = false,
        relativenumber = false,
        cursorline = false,
      },
    },
    plugins = {
      options = {
        enabled = true,
        ruler = false,
        showcmd = false,
        laststatus = 0,
      },
      twilight = { enabled = true },
      gitsigns = { enabled = true },
    },
    on_open = function(win)
      vim.g.zen_mode_active = true
      local group = vim.api.nvim_create_augroup("ZenModeNeoTree", { clear = true })
      vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function()
          local ft = vim.bo.filetype
          if vim.g.zen_mode_active and ft ~= "neo-tree" and ft ~= "" then
            vim.defer_fn(function()
              vim.wo.number = false
              vim.wo.relativenumber = false
              vim.wo.cursorline = false
            end, 50)
          end
        end,
      })
    end,
    on_close = function()
      vim.g.zen_mode_active = false
      pcall(vim.api.nvim_del_augroup_by_name, "ZenModeNeoTree")
    end,
  },
}
