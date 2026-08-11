return {
  {
    "folke/which-key.nvim",
    opts = {
      win = {
        -- Allow the popup to use the available editor area instead of
        -- collapsing to a one-row window near the cursor.
        no_overlap = false,
        height = { min = 8, max = 20 },
      },
    },
  },
}
