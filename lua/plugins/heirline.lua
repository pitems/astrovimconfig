return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local state = require "core.buffer_groups.state"

    local group_component = {
      provider = function()
        if not state.active_group then return "" end
        return "  " .. state.active_group .. " "
      end,
      hl = { fg = "black", bg = "green", bold = true },
    }

    table.insert(opts.statusline, 1, group_component)

    return opts
  end,
}
