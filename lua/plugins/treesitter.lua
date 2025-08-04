-- Remove this line if it's still there
-- if true then return {} end

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false, -- important!
    dependencies = { "OXY2DEV/markview.nvim" },
    opts = {
      ensure_installed = {
        "lua",
        "vim",
        "markdown",
        "markdown_inline",
        -- Add more languages if needed
      },
    },
  },
}
