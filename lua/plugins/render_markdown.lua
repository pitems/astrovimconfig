return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-mini/mini.icons",
  },
  opts = {
    render_modes = true,
    anti_conceal = {
      enabled = false, -- Astro already messes with this
    },
  },
}
