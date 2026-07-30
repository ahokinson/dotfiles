return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      
      lint.linters_by_ft = {
        -- Go
        go = { "golangcilint" },
        -- Python
        python = { "ruff" },
        -- JavaScript/TypeScript
        javascript = { "eslint" },
        javascriptreact = { "eslint" },
        typescript = { "eslint" },
        typescriptreact = { "eslint" },
        -- Infrastructure as Code
        terraform = { "tflint" },
        tf = { "tflint" },
        helm = { "yamllint" },
        yaml = { "yamllint" },
        -- Containers
        dockerfile = { "hadolint" },
        -- Markdown
        markdown = { "markdownlint" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          if not vim.opt_local.modifiable:get() then
            return
          end

          local ft = vim.bo.filetype
          local linters = lint.linters_by_ft[ft]
          if not linters then
            return
          end

          -- Only run linters whose command is available
          local available = {}
          for _, name in ipairs(linters) do
            local linter = lint.linters[name]
            local cmd = linter and linter.cmd
            if type(cmd) == "function" then
              cmd = cmd()
            end
            if cmd and vim.fn.executable(cmd) == 1 then
              table.insert(available, name)
            end
          end

          if #available > 0 then
            lint.try_lint(available)
          end
        end,
      })

      vim.api.nvim_create_user_command("Lint", function()
        lint.try_lint()
      end, { desc = "Trigger linting for current file" })
    end,
  },
}
