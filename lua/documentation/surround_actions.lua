local M = {}

local function feed(keys)
  local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(termcodes, "n", false)
end

function M.add()
  feed("gza")
end

function M.delete()
  feed("gzd")
end

function M.replace()
  feed("gzr")
end

function M.highlight()
  feed("gzh")
end

function M.find_next()
  feed("gzn")
end

function M.find_prev()
  feed("gzp")
end

function M.update_lines()
  feed("gzl")
end

return M
