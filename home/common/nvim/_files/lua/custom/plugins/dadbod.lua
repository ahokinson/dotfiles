return {
  {
    "tpope/vim-dadbod",
    lazy = true,
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = {
      "DB",
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_use_nerd_fonts = vim.g.have_nerd_font
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_icons = {
        expanded = {
          db = "▾ ",
          buffers = "▾ ",
          saved_queries = "▾ ",
          schemas = "▾ ",
          schema = "▾ ",
          tables = "▾ ",
          table = "▾ ",
        },
        collapsed = {
          db = "▸ ",
          buffers = "▸ ",
          saved_queries = "▸ ",
          schemas = "▸ ",
          schema = "▸ ",
          tables = "▸ ",
          table = "▸ ",
        },
        saved_query = "",
        new_query = "󰓰 ",
        tables = "󱏒 ",
        buffers = "󰈙 ",
        add_connection = "󰆺 ",
        connection_ok = "✓ ",
        connection_error = "✕ ",
      }
      vim.g.db_ui_execute_on_save = false
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
            },
          })
        end,
      })
    end,
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Toggle [D]ata[b]ase UI" },
      { "<leader>dB", "<cmd>DBUIFindBuffer<CR>", desc = "[D]ata[B]ase: Find Buffer" },
      { "<leader>dr", "<cmd>DBUIRenameBuffer<CR>", desc = "[D]ata[b]ase: [R]ename Buffer" },
      { "<leader>dq", "<cmd>DBUILastQueryInfo<CR>", desc = "[D]ata[b]ase: Last [Q]uery Info" },
    },
  },
}
