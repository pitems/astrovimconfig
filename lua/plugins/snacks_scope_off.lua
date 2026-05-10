return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.indent = opts.indent or {}
    opts.indent.enabled = false
    opts.scope = opts.scope or {}
    opts.scope.enabled = false
  end,
}
