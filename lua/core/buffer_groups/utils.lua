-- core/buffer_groups/utils.lua

local M = {}

function M.setup_keymaps()
  vim.keymap.set(
    "n",
    "<C-g>",
    function() require("core.buffer_groups.ui").open_menu() end,
    { desc = "Buffer Groups Menu" }
  )
end

return M
