return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "williamboman/mason.nvim", opts = {} },
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    { "j-hui/fidget.nvim", opts = {} },

    "hrsh7th/cmp-nvim-lsp",
    { "folke/lsp-colors.nvim", opts = {} },
  },
  config = require("custom.safe").config(function()
    local function client_supports(client, method, bufnr)
      if not client then
        return false
      end
      if type(client.supports_method) == "function" then
        local ok, result = pcall(client.supports_method, client, method, { bufnr = bufnr })
        if ok then
          return result
        end
      end
      return false
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("<leader>GD", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("<leader>Gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("<leader>GI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>Gt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")
        map("<leader>Gds", require("telescope.builtin").lsp_document_symbols, "[G]oto [D]ocument [S]ymbols")
        map("<leader>Gws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[G]oto [W]orkspace [S]ymbols")
        map("<leader>Gd", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, "Go to previous [D]iagnostic")
        map("]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, "Go to next [D]iagnostic")
        map("<leader>e", vim.diagnostic.open_float, "Show diagnostic [E]rror messages")
        map("<leader>th", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
        end, "[T]oggle Inlay [H]ints")

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client_supports(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
            end,
          })
        end
      end,
    })

    vim.diagnostic.config({
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      } or {},
      virtual_text = {
        source = "if_many",
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
    vim.lsp.config("*", { capabilities = capabilities })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          workspace = {
            checkThirdParty = false,
            library = {
              "${3rd}/luv/library",
              unpack(vim.api.nvim_get_runtime_file("", true)),
            },
          },
          completion = { callSnippet = "Replace" },
          telemetry = { enable = false },
          diagnostics = { disable = { "missing-fields" } },
        },
      },
    })

    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
            shadow = true,
          },
          staticcheck = true,
          usePlaceholders = true,
          completeUnimported = true,
        },
      },
    })

    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            command = "clippy",
          },
        },
      },
    })

    vim.lsp.config("ty", {
      cmd = { vim.fn.stdpath("data") .. "/mason/bin/ty" },
      filetypes = { "python" },
      root_markers = { "pyproject.toml", "ty.toml", ".git" },
    })

    local inlayHints = {
      includeInlayParameterNameHints = "all",
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    }
    vim.lsp.config("ts_ls", {
      settings = {
        typescript = { inlayHints = inlayHints },
        javascript = { inlayHints = inlayHints },
      },
    })

    vim.lsp.config("terraformls", {
      settings = {
        terraform = {
          validation = {
            enableEnhancedValidation = true,
          },
        },
      },
    })

    vim.lsp.config("helm_ls", {
      settings = {
        ["helm-ls"] = {
          yamlls = {
            path = "yaml-language-server",
          },
        },
      },
    })

    vim.lsp.config("yamlls", {
      settings = {
        yaml = {
          schemas = {
            kubernetes = "*.yaml",
            ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
            ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
            ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
            ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
            ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
            ["http://json.schemastore.org/ansible-playbook"] = "*play*.{yml,yaml}",
            ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
            ["https://json.schemastore.org/dependabot-v2"] = ".github/dependabot.{yml,yaml}",
            ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
            ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
          },
          format = { enable = true },
          validate = true,
          completion = true,
          hover = true,
        },
      },
    })

    local servers = {
      "lua_ls",
      "gopls",
      "rust_analyzer",
      "zls",
      "ty",
      "ts_ls",
      "terraformls",
      "helm_ls",
      "yamlls",
      "dockerls",
      "docker_compose_language_service",
      "marksman",
    }

    for _, server in ipairs(servers) do
      vim.lsp.enable(server)
    end

    local mason_lsp_servers = {}
    for _, name in ipairs(servers) do
      if name ~= "ty" then
        mason_lsp_servers[#mason_lsp_servers + 1] = name
      end
    end

    local ensure_installed = {
      "stylua",
      "golangci-lint",
      "ruff",
      "prettier",
      "eslint",
      "tflint",
      "yamllint",
      "hadolint",
      "markdownlint",
      "codelldb",
      "debugpy",
      "delve",
      "js-debug-adapter",
      "ty",
    }
    vim.list_extend(ensure_installed, mason_lsp_servers)
    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

    require("mason-lspconfig").setup({
      ensure_installed = mason_lsp_servers,
      automatic_installation = false,
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
          local lspconfig = require("lspconfig")
          local cfg = lspconfig[server_name]
          if not cfg then
            vim.schedule(function()
              vim.notify(("[safe] unknown LSP server: %s"):format(server_name), vim.log.levels.WARN)
            end)
            return
          end
          local ok, err = pcall(cfg.setup, server)
          if not ok then
            vim.schedule(function()
              vim.notify(("[safe] LSP setup failed for %s: %s"):format(server_name, err), vim.log.levels.ERROR)
            end)
          end
        end,
      },
    })
  end),
}
