local M = {}

local width_by_filetype = {
  dart = 120,
  html = 120,
  typescript = 120,
  typescriptreact = 120,
  javascript = 120,
  javascriptreact = 120,
  ts = 120,
  tsx = 120,
  js = 120,
  jsx = 120,
  vue = 120,
}

function M.apply(filetype)
  local width = width_by_filetype[filetype]
  if filetype == "markdown" or filetype == "md" then
    -- Markdown should adapt to the current window so vertical splits still wrap
    -- into readable paragraphs instead of stretching across the whole line.
    local win_width = vim.api.nvim_win_get_width(0)
    width = math.max(40, math.min(120, win_width - 4))
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.breakindent = true
    vim.opt_local.formatoptions:append("t")
  end

  if not width then
    return
  end

  -- Keep the buffer-local width and visual guide aligned for formatter testing.
  vim.bo.textwidth = width
  vim.wo.colorcolumn = tostring(width)
  if filetype == "markdown" or filetype == "md" then
    vim.notify(string.format("Markdown wrap width set to %d", width), vim.log.levels.INFO)
  end
end

return M
