local parsers = {
  "bash",
  "c",
  "diff",
  "go",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
  "zig",
}

-- Incremental selection (the `master`-branch module was removed on `main`).
-- Reselects progressively larger/smaller treesitter nodes around the cursor.
local incremental = {}
do
  local nodes = {}

  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)

  local function range_eq(a, b)
    local a1, a2, a3, a4 = a:range()
    local b1, b2, b3, b4 = b:range()
    return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
  end

  local function update_selection(node)
    if not node then
      return
    end
    local srow, scol, erow, ecol = node:range()
    -- Treesitter end column is exclusive; resolve to the last selected char.
    if ecol == 0 then
      erow = erow - 1
      ecol = #(vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1] or "")
    end

    -- Leave any current visual selection before starting a fresh one.
    if vim.api.nvim_get_mode().mode:match("[vV\22]") then
      vim.api.nvim_feedkeys(esc, "x", false)
    end

    vim.fn.setpos(".", { 0, srow + 1, scol + 1, 0 })
    vim.cmd("normal! v")
    vim.fn.setpos(".", { 0, erow + 1, ecol, 0 })
  end

  function incremental.init()
    local node = vim.treesitter.get_node()
    if not node then
      return
    end
    nodes = { node }
    update_selection(node)
  end

  function incremental.increment()
    local node = nodes[#nodes]
    if not node then
      return incremental.init()
    end
    local parent = node:parent()
    while parent and range_eq(parent, node) do
      parent = parent:parent()
    end
    if parent then
      nodes[#nodes + 1] = parent
      update_selection(parent)
    else
      update_selection(node)
    end
  end

  function incremental.decrement()
    if #nodes > 1 then
      nodes[#nodes] = nil
    end
    update_selection(nodes[#nodes])
  end
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = function()
    -- Install only missing parsers (the `main`-branch `install()` is async and
    -- re-fetches every parser it's handed, so diff against what's already built).
    local nt = require("nvim-treesitter")
    local have = {}
    for _, lang in ipairs(nt.get_installed()) do
      have[lang] = true
    end
    local todo = vim.tbl_filter(function(p)
      return not have[p]
    end, parsers)
    if #todo > 0 then
      nt.install(todo)
    end
  end,
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
      config = function()
        require("nvim-treesitter-textobjects").setup({ move = { set_jumps = true } })

        local select = require("nvim-treesitter-textobjects.select")
        local move = require("nvim-treesitter-textobjects.move")
        local swap = require("nvim-treesitter-textobjects.swap")
        local map = vim.keymap.set

        -- select
        local selects = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        }
        for lhs, obj in pairs(selects) do
          map({ "x", "o" }, lhs, function()
            select.select_textobject(obj, "textobjects")
          end, { desc = "Select " .. obj })
        end

        -- move
        map({ "n", "x", "o" }, "]f", function()
          move.goto_next_start("@function.outer", "textobjects")
        end)
        map({ "n", "x", "o" }, "]c", function()
          move.goto_next_start("@class.outer", "textobjects")
        end)
        map({ "n", "x", "o" }, "]a", function()
          move.goto_next_start("@parameter.inner", "textobjects")
        end)
        map({ "n", "x", "o" }, "]F", function()
          move.goto_next_end("@function.outer", "textobjects")
        end)
        map({ "n", "x", "o" }, "]C", function()
          move.goto_next_end("@class.outer", "textobjects")
        end)
        map({ "n", "x", "o" }, "]A", function()
          move.goto_next_end("@parameter.inner", "textobjects")
        end)
        map({ "n", "x", "o" }, "[f", function()
          move.goto_previous_start("@function.outer", "textobjects")
        end)
        map({ "n", "x", "o" }, "[c", function()
          move.goto_previous_start("@class.outer", "textobjects")
        end)
        map({ "n", "x", "o" }, "[a", function()
          move.goto_previous_start("@parameter.inner", "textobjects")
        end)
        map({ "n", "x", "o" }, "[F", function()
          move.goto_previous_end("@function.outer", "textobjects")
        end)
        map({ "n", "x", "o" }, "[C", function()
          move.goto_previous_end("@class.outer", "textobjects")
        end)
        map({ "n", "x", "o" }, "[A", function()
          move.goto_previous_end("@parameter.inner", "textobjects")
        end)

        -- swap
        map("n", "<leader>psn", function()
          swap.swap_next("@parameter.inner")
        end, { desc = "Swap next parameter" })
        map("n", "<leader>psp", function()
          swap.swap_previous("@parameter.inner")
        end, { desc = "Swap previous parameter" })
      end,
    },
  },
  config = require("custom.safe").config(function()
    require("nvim-treesitter").install(parsers)

    -- Start highlighting + indent only when a parser is actually available,
    -- so filetypes without a parser don't error.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if not (lang and pcall(vim.treesitter.start, args.buf, lang)) then
          return
        end
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- Incremental selection keymaps (replaces removed master-branch module).
    vim.keymap.set("n", "<C-space>", incremental.init, { desc = "Init selection" })
    vim.keymap.set("x", "<C-space>", incremental.increment, { desc = "Increment selection" })
    vim.keymap.set("x", "<bs>", incremental.decrement, { desc = "Decrement selection" })
  end),
}
