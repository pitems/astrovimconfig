local show_only_pinned = false
return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}

    opts.options.indicator = {
      style = "underline",
      icon = "",
    }
    opts.options.tab_size = 18 -- or 20 if you want chunky tabs
    opts.options.max_name_length = 18
    opts.options.separator_style = "slant"
    opts.options.themable = true

    return opts
  end,
  config = function(_, opts)
    require("bufferline").setup(opts)

    vim.keymap.set("n", "<leader>bt", "<cmd>BufferLineGroupToggle pinned<cr>", {
      desc = "Toggle pinned buffers",
    })
  end,
}
