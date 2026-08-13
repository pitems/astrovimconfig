local M = {}

local function copy(value, description)
  vim.fn.setreg("+", value)
  vim.fn.setreg("*", value)
  vim.notify("Copied " .. description .. ": " .. value, vim.log.levels.INFO)
end

function M.relative_path()
  copy(vim.fn.expand "%:.", "relative path")
end

function M.absolute_path()
  copy(vim.fn.expand "%:p", "absolute path")
end

function M.filename()
  copy(vim.fn.expand "%:t", "filename")
end

function M.directory()
  copy(vim.fn.expand "%:p:h", "containing directory")
end

return M
