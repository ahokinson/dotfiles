local M = {}

local readme_rank = { md = 1, rst = 2, txt = 3 }

local function should_open()
  if vim.fn.argc(-1) > 0 then
    return false
  end

  local buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].modified then
    return false
  end

  local wins = vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_config(win).relative == ""
  end, vim.api.nvim_list_wins())
  if #wins ~= 1 then
    return false
  end

  local uis = vim.api.nvim_list_uis()
  if #uis == 0 or (uis[1].stdout_tty and not uis[1].stdin_tty) then
    return false
  end

  if vim.api.nvim_buf_line_count(buf) > 1 then
    return false
  end
  return #(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "") == 0
end

local function recent_file(cwd)
  local dashboard = require("custom.safe").require("snacks.dashboard")
  if not dashboard then
    return nil
  end

  for file in dashboard.oldfiles({ filter = { [cwd] = true } }) do
    if not file:find("/%.git/") and vim.fn.filereadable(file) == 1 then
      return file
    end
  end
end

local function readme(cwd)
  local best, best_rank = nil, math.huge

  for name in vim.fs.dir(cwd) do
    if name:lower():find("^readme") and vim.fn.filereadable(cwd .. "/" .. name) == 1 then
      local rank = readme_rank[name:lower():match("%.(%w+)$") or ""] or 4
      if rank < best_rank then
        best, best_rank = name, rank
      end
    end
  end

  return best and (cwd .. "/" .. best) or nil
end

function M.setup()
  vim.api.nvim_create_user_command("Dashboard", function()
    local dashboard = require("custom.safe").require("snacks.dashboard")
    if dashboard then
      dashboard.open()
    end
  end, { desc = "Open the snacks dashboard" })

  if not should_open() then
    return
  end

  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local file = recent_file(cwd) or readme(cwd)
  if file then
    vim.cmd.edit(vim.fn.fnameescape(file))
  end
end

return M
