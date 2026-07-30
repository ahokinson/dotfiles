return {
  -- Plugin repository
  "MeanderingProgrammer/render-markdown.nvim",

  -- Lazy load on markdown files or when the toggle keybinding is used
  ft = { "markdown" },
  cmd = { "RenderMarkdown" },
  keys = {
    { "<leader>mr", function() require("render-markdown").toggle() end, desc = "Toggle Markdown Rendering" },
  },

  -- Specify dependencies
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons"
  },

  -- Configure the plugin
  config = function()
    -- Setup the render-markdown plugin with sensible defaults
    require("render-markdown").setup({
      -- Whether markdown should be rendered by default
      enabled = true,
      
      -- Vim modes that will show a rendered view of the markdown file
      render_modes = { 'n', 'c', 't' },
      
      -- Filetypes this plugin will run on
      file_types = { 'markdown' },
      
      -- Pre-configured settings ('obsidian', 'lazy', or 'none')
      preset = 'none',
      
      -- Anti-conceal: prevent cursor line from being un-rendered
      anti_conceal = {
        enabled = false,
      },
      
      -- Heading configuration
      heading = {
        -- Turn on/off heading icon & background rendering
        enabled = true,
        -- Icons for different heading levels
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        -- Width of the heading background ('full' or 'block')
        width = 'block',
        -- Add padding to headings for better visual separation
        left_pad = 1,
        right_pad = 1,
      },
      
      -- Code block configuration
      code = {
        -- Turn on/off code block rendering
        enabled = true,
        -- Turn on/off language heading related rendering
        language = true,
        -- Whether to include the language icon above code blocks
        language_icon = true,
        -- Whether to include the language name above code blocks
        language_name = true,
      },
      
      -- List bullet configuration
      bullet = {
        -- Turn on/off list bullet rendering
        enabled = true,
        -- Icons for different bullet levels
        icons = { '●', '○', '◆', '◇' },
      },
      
      -- Checkbox configuration
      checkbox = {
        -- Turn on/off checkbox state rendering
        enabled = true,
        -- Render the bullet point before the checkbox
        bullet = false,
        -- Unchecked checkbox settings
        unchecked = {
          -- Icon for unchecked checkboxes
          icon = '󰄱 ',
        },
        -- Checked checkbox settings
        checked = {
          -- Icon for checked checkboxes
          icon = '󰱒 ',
        },
      },
      
      -- Block quote configuration
      quote = {
        -- Turn on/off block quote rendering
        enabled = true,
        -- Icon for block quotes
        icon = '▋',
      },
      
      -- Table configuration
      pipe_table = {
        -- Turn on/off pipe table rendering
        enabled = true,
        -- How cells are rendered ('padded', 'raw', 'overlay', 'trimmed')
        cell = 'padded',
      },
    })
  end,
}
