return {
  "zaldih/themery.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = { "Themery" },
  opts = {
    themes = {
      { name = "AstroDark", colorscheme = "astrodark" },
      { name = "Catppuccin", colorscheme = "catppuccin" },
      { name = "Tokyo Night", colorscheme = "tokyonight" },
      { name = "Kanagawa", colorscheme = "kanagawa" },
      { name = "Rose Pine", colorscheme = "rose-pine" },
      { name = "Gruvbox", colorscheme = "gruvbox" },
      { name = "Terafox", colorscheme = "terafox"},
      {name = "CyberDream" , colorscheme = 'cyberdream'}

    },
    livePreview = true, -- instantly preview on select
    livePreviewValidOnly = true, -- skip themes that aren't installed
    configFile = vim.fn.stdpath("config") .. "/lua/user/theme.lua",
  },
}
