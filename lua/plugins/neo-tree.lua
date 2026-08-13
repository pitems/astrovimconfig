return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.window = opts.window or {}
    opts.window.mappings = opts.window.mappings or {}

    -- Keep the global Tab mappings for real Neovim tabs everywhere else.
    -- Inside Neo-tree, use them to cycle through Files, Buffers, and Git.
    opts.window.mappings["<Tab>"] = "next_source"
    opts.window.mappings["<S-Tab>"] = "prev_source"

    return opts
  end,
}
