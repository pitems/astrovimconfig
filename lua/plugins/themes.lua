return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    opts = {
      transparent = false,
      -- on_highlights = function(hl, colors)
      --   local bg = colors.bg
      --   local fg = colors.fg
      --   local inactive = colors.fg_dark
      --   local orange = "#FF9E64"
      --
      --   -- 🔥 Base
      --   hl.BufferLineFill = { bg = bg }
      --   hl.BufferLineBackground = { fg = inactive, bg = bg }
      --
      --   -- 🔥 Selected buffer (THE IMPORTANT ONE)
      --   hl.BufferLineBufferSelected = {
      --     fg = fg,
      --     bg = bg,
      --     sp = orange,
      --     underline = true,
      --     bold = true,
      --   }
      --
      --   -- 🔥 Inactive buffers
      --   hl.BufferLineBuffer = {
      --     fg = inactive,
      --     bg = bg,
      --   }
      --
      --   -- 🔥 Visible buffers
      --   hl.BufferLineBufferVisible = {
      --     fg = fg,
      --     bg = bg,
      --   }
      --
      --   -- 🔥 Tabs (fallback killers)
      --   hl.TabLine = { fg = inactive, bg = bg }
      --   hl.TabLineSel = { fg = fg, bg = bg }
      --   hl.TabLineFill = { bg = bg }
      --
      --   -- 🔥 WildMenu fallback
      --   hl.WildMenu = { fg = fg, bg = bg }
      --
      --   -- 🔥 Kill syntax leaks
      --   hl.String = { fg = fg }
      --   hl.Constant = { fg = fg }
      --   hl.Comment = { fg = inactive }
      --
      --   -- 🔥 Separators (slants)
      --   hl.BufferLineSeparator = { fg = bg, bg = bg }
      --   hl.BufferLineSeparatorSelected = { fg = bg, bg = bg }
      --   hl.BufferLineSeparatorVisible = { fg = bg, bg = bg }
      -- end,
    },
  },
  { "rebelot/kanagawa.nvim" },
  -- { "rose-pine/neovim", name = "rose-pine" },
  -- { "ellisonleao/gruvbox.nvim" },
  { "EdenEast/nightfox.nvim" },
  { "scottmckendry/cyberdream.nvim", priority = 1000 },
  {
    "oskarnurm/koda.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- require("koda").setup({ transparent = true })
      -- vim.cmd("colorscheme koda")
    end,
  },
  { "Mofiqul/dracula.nvim" },
  {
    "pitems/luna.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      plugins = {
        all = true,
        auto = true,
      },
    },
    config = function(_, opts) require("luna").setup(opts) end,
  },
  -- {
  --   "zenbones-theme/zenbones.nvim",
  --   -- Optionally install Lush. Allows for more configuration or extending the colorscheme
  --   -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
  --   -- In Vim, compat mode is turned on as Lush only works in Neovim.
  --   dependencies = "rktjmp/lush.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   -- you can set set configuration options here
  --   -- config = function()
  --   --     vim.g.zenbones_darken_comments = 45
  --   --     vim.cmd.colorscheme('zenbones')
  --   -- end
  -- },
}
