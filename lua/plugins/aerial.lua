return {
  "stevearc/aerial.nvim",
  opts = {
    backends = { "lsp" },
  },
  dependencies = {
     "nvim-treesitter/nvim-treesitter",
     "nvim-tree/nvim-web-devicons"
  },
  keys = {
    { "<leader>o", "<cmd>AerialToggle<CR>", desc = "Toggle Aerial" },
  },
}
