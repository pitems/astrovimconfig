return {
  "nvim-pack/nvim-spectre",
  event = "VeryLazy",
  cmd = "Spectre",
  opts = {
    open_cmd = "vnew", -- or "new" / "tabnew" / "vsplit"
    live_update = true,
    line_sep_start = "╭─────────────────────────────────────────",
    result_padding = "│ ",
    line_sep       = "╰─────────────────────────────────────────",
  },
}
