local M = {}

function M.require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.schedule(function()
      vim.notify(("[safe] require('%s') failed: %s"):format(mod, m), vim.log.levels.ERROR)
    end)
    return nil
  end
  return m
end

function M.config(fn)
  return function(...)
    local args = { ... }
    local ok, err = xpcall(function()
      return fn(unpack(args))
    end, debug.traceback)
    if not ok then
      vim.schedule(function()
        vim.notify("[safe] plugin config failed:\n" .. err, vim.log.levels.ERROR)
      end)
    end
  end
end

return M
