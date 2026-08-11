return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Debug: Set Conditional Breakpoint",
      },
      {
        "<leader>dgb",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Debug: Run to Cursor",
      },
      {
        "<leader>d?",
        function()
          require("dapui").eval(nil, { enter = true })
        end,
        desc = "Debug: Evaluate Expression",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Debug: Continue",
      },
      {
        "<leader>dsi",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: Step Into",
      },
      {
        "<leader>dso",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: Step Over",
      },
      {
        "<leader>dst",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: Step Out",
      },
      {
        "<leader>dsb",
        function()
          require("dap").step_back()
        end,
        desc = "Debug: Step Back",
      },
      {
        "<leader>dr",
        function()
          require("dap").restart()
        end,
        desc = "Debug: Restart",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Debug: Terminate",
      },
      {
        "<leader>dgt",
        function()
          require("dap-go").debug_test()
        end,
        desc = "Debug: Go Test",
      },
      {
        "<leader>dgl",
        function()
          require("dap-go").debug_last_test()
        end,
        desc = "Debug: Go Last Test",
      },
      {
        "<leader>dpt",
        function()
          require("dap-python").test_method()
        end,
        desc = "Debug: Python Test Method",
      },
      {
        "<leader>dpc",
        function()
          require("dap-python").test_class()
        end,
        desc = "Debug: Python Test Class",
      },
      {
        "<leader>dps",
        function()
          require("dap-python").debug_selection()
        end,
        desc = "Debug: Python Selection",
        mode = "v",
      },
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-telescope/telescope-dap.nvim",
      "williamboman/mason.nvim",
      "nvim-neotest/nvim-nio",

      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
      "mxsdev/nvim-dap-vscode-js",
    },
    config = require("custom.safe").config(function()
      local dap = require("dap")
      local ui = require("dapui")

      require("dapui").setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        },
      })

      -- Go
      require("dap-go").setup({
        delve = {
          path = "dlv",
          initialize_timeout_sec = 20,
          port = 38697,
          args = {},
          build_flags = "",
        },
        dap_debug_gui = true,
        dap_debug_test = true,
      })

      -- Python
      local debugpy_python = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
      
      if vim.fn.executable(debugpy_python) == 1 then
        require("dap-python").setup(debugpy_python)
      else
        require("dap-python").setup("python3")
      end

      dap.configurations.python = dap.configurations.python or {}

      local function python_path()
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
          return cwd .. "/venv/bin/python"
        elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
          return cwd .. "/.venv/bin/python"
        end
        local python3 = vim.fn.exepath("python3")
        return python3 ~= "" and python3 or "python3"
      end
      
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = python_path,
      })

      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch file with arguments",
        program = "${file}",
        args = function()
          local args_string = vim.fn.input("Arguments: ")
          return vim.split(args_string, " +")
        end,
        pythonPath = python_path,
      })

      table.insert(dap.configurations.python, {
        type = "python",
        request = "attach",
        name = "Attach remote",
        connect = function()
          local host = vim.fn.input("Host [127.0.0.1]: ")
          host = host ~= "" and host or "127.0.0.1"
          local port = tonumber(vim.fn.input("Port [5678]: ")) or 5678
          return { host = host, port = port }
        end,
      })

      -- Rust/Zig
      local codelldb_path = vim.fn.expand("~/.local/share/nvim/mason/bin/codelldb")
      
      if vim.fn.executable(codelldb_path) == 1 then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = codelldb_path,
            args = { "--port", "${port}" },
          },
        }

        dap.configurations.rust = {
          {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
          {
            name = "Launch file (release)",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/release/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        }

        dap.configurations.zig = {
          {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/zig-out/bin/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        }
      end

      -- JavaScript/TypeScript
      local js_debug_path = vim.fn.expand("~/.local/share/nvim/mason/packages/js-debug-adapter")
      
      if vim.fn.isdirectory(js_debug_path) == 1 then
        require("dap-vscode-js").setup({
          debugger_path = js_debug_path,
          adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
        })

        for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "launch",
              name = "Debug Jest Tests",
              runtimeExecutable = "node",
              runtimeArgs = {
                "./node_modules/jest/bin/jest.js",
                "--runInBand",
              },
              rootPath = "${workspaceFolder}",
              cwd = "${workspaceFolder}",
              console = "integratedTerminal",
              internalConsoleOptions = "neverOpen",
            },
            {
              type = "pwa-chrome",
              request = "launch",
              name = "Launch Chrome",
              url = function()
                local url = vim.fn.input("URL: ", "http://localhost:3000")
                return url
              end,
              webRoot = "${workspaceFolder}",
            },
          }
        end
      end

      require("nvim-dap-virtual-text").setup({
        display_callback = function(variable)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)
          if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
            return "*****"
          end

          if #variable.value > 15 then
            return " " .. string.sub(variable.value, 1, 15) .. "... "
          end

          return " " .. variable.value
        end,
      })

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end),
  },
}
