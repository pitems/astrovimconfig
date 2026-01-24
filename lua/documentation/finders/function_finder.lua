local M = {}

local FUNCTION_REGEX = "([%w_]+)%s*%([^)]*%)%s*{"

function M.find(bufnr, parse_with_regex)
  local raw = parse_with_regex(bufnr, FUNCTION_REGEX)
  local results = {}

  for _, item in ipairs(raw) do
    table.insert(results, {
      name = item.name,
      line = item.row,
    })
  end

  return results
end

return M
