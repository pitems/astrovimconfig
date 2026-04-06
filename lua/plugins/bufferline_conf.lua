local show_only_pinned = false
return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}

    --   if not show_only_pinned then return true end
    --
    --   -- 🔥 correct way to check if pinned
    --   local groups = require "bufferline.groups"
    --   local bufdata = groups.get_buf(buf)
    --
    --   return bufdata and bufdata.pinned
    -- end
    --
    return opts
  end,
  config = function(_, opts)
    require("bufferline").setup(opts)

    vim.keymap.set("n", "<leader>bt", "<cmd>BufferLineGroupToggle pinned<cr>", {
      desc = "Toggle pinned buffers",
    })
  end,
}
