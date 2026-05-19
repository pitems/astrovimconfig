local M = {}

function M.reflow()
  local filetype = vim.bo.filetype
  if filetype ~= "markdown" and filetype ~= "md" then
    vim.notify("Markdown reflow only works in markdown buffers", vim.log.levels.WARN)
    return
  end

  -- Recompute the wrap width before formatting so narrow splits still reflow well.
  require("user.format_widths").apply(filetype)

  local width = vim.bo.textwidth
  if width <= 0 then
    local win_width = vim.api.nvim_win_get_width(0)
    width = math.max(40, math.min(120, win_width - 4))
    vim.bo.textwidth = width
  end

  -- Reflow the whole buffer using the current textwidth so long notes wrap below.
  vim.cmd("silent keepjumps normal! ggVGgq")
  vim.notify(string.format("Markdown reflow applied at width %d", width), vim.log.levels.INFO)
end

return M
