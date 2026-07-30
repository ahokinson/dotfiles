return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "\\", ":Neotree float toggle<CR>", desc = "Toggle NeoTree (float)", silent = true },
  },
  opts = {
    close_if_last_window = false,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,

    window = {
      position = "float",
      width = 40,
      popup = {
        size = function()
          local width = vim.o.columns
          local height = vim.o.lines
          return {
            height = math.floor(height * 0.8),
            width = math.min(100, math.floor(width * 0.5)),
          }
        end,
        position = "50%",
        title = function()
          local cwd = vim.fn.getcwd()
          local project_name = vim.fn.fnamemodify(cwd, ":t")
          return " " .. project_name .. " "
        end,
        title_pos = "center",
      },
      mappings = {
        ["\\"] = "close_window",
        ["<esc>"] = "close_window",
      },
    },

    filesystem = {
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          "node_modules",
          ".git",
          ".DS_Store",
          "thumbs.db",
        },
        hide_by_pattern = {
          "*.pyc",
        },
        never_show = {
          ".next",
          "dist",
          "build",
          "out",
          "target",
          ".output",
          ".nuxt",
          ".cache",
          "__pycache__",
          ".pytest_cache",
          ".venv",
          "venv",
          ".eggs",
        },
      },
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
    },
  },
}
