local function_finder = require("documentation.finders.function_finder")

local M = {}

-- low-level helper (shared)
function M.parse_with_regex(bufnr, regex)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local results = {}

  for row, line in ipairs(lines) do
    local col_start, col_end, match = line:find(regex)
    if match then
      table.insert(results, {
        name = match,
        row = row - 1,
        col = col_start - 1,
        line = line,
      })
    end
  end

  return results
end

-- public parser API
function M.parse(source_lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, source_lines)

  local functions = function_finder.find(buf, M.parse_with_regex)

  vim.api.nvim_buf_delete(buf, { force = true })

  return {
    functions = functions,
  }
end

return M
