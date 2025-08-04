return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Telescope", -- optional lazy-load trigger
  config = function()
    require("telescope").setup()
  end,
}
