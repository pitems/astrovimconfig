return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"
    local state = require "core.buffer_groups.state"
    local rounded = { "", "" }

    local group_component = status.utils.surround(rounded, "green", {
      provider = function()
        if not state.active_group then return "" end
        return "  " .. state.active_group .. " "
      end,
      hl = { fg = "black", bg = "green", bold = true },
    }, function() return state.active_group ~= nil end)

    opts.statusline = {
      hl = { fg = "fg", bg = "bg" },
      status.component.mode {
        mode_text = {},
        surround = {
          separator = rounded,
          color = function() return status.hl.mode_bg() end,
        },
      },
      group_component,
      status.component.git_branch {
        surround = {
          separator = rounded,
          color = "git_branch_bg",
        },
      },
      status.component.file_info {
        filename = {},
        filetype = false,
        surround = {
          separator = rounded,
          color = "file_info_bg",
        },
      },
      status.component.git_diff {
        surround = {
          separator = rounded,
          color = "git_diff_bg",
        },
      },
      status.component.diagnostics {
        surround = {
          separator = rounded,
          color = "diagnostics_bg",
        },
      },
      status.component.fill(),
      status.component.lsp(),
      status.component.virtual_env(),
      status.component.treesitter(),
      status.component.nav {
        surround = {
          separator = rounded,
          color = "nav_bg",
        },
      },
    }

    return opts
  end,
}
