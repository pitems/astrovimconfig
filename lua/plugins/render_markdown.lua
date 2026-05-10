return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-mini/mini.icons",
  },
  opts = {
    -- Keep the plugin available, but do not auto-attach on markdown open.
    -- This avoids treesitter-related startup errors while preserving the
    -- manual :RenderMarkdown commands.
    enabled = true,
    render_modes = true,
    anti_conceal = {
      enabled = false, -- Astro already messes with this
    },
  },
}
