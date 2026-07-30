return {
  "laytan/cloak.nvim",
  config = function()
    require("cloak").setup({
      enabled = true,
      cloak_character = "*",
      highlight_group = "Comment",
      try_all_patterns = true,
      cloak_telescope = true,
      patterns = {
        {
          file_pattern = {
            "*.env*",
            "*.conf",
            "*.ini",
            "*.toml",
          },
          cloak_pattern = "=.+",
        },
        {
          file_pattern = {
            "*.y*ml",
            "*.json*",
          },
          cloak_pattern = ":\\s*.+",
        },
        {
          file_pattern = {
            "*.key",
            "*.pem",
            "*.pub",
            "id_*",
            "*.crt",
            "*.cer",
            "*authorized_keys",
            "*known_hosts",
          },
          cloak_pattern = {
            "-----BEGIN.*",
            "-----END.*",
            "ssh-rsa.*",
            "ssh-ed25519.*",
            "ecdsa-sha2.*",
            "[0-9a-zA-Z-_=+/]{8,}",
          },
        },
      },
    })

    vim.keymap.set("n", "<leader>cs", ":CloakToggle<CR>", { silent = true, desc = "Toggle Secret Cloaking" })
    vim.keymap.set("n", "<leader>cp", ":CloakPreviewLine<CR>", { silent = true, desc = "Preview Cloaked Line" })
  end,
}
