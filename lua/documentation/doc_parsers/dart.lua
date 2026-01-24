local M = {}

function M.parse(lines)
  local functions = {}

  for _, line in ipairs(lines) do
    local return_type, name =
      line:match("^%s*([%w_<>,]+)%s+(%w+)%s*%(")

    if return_type and name then
      table.insert(functions, {
        name = name,
        return_type = return_type,
      })
    end
  end

  return {
    functions = functions,
  }
end

return M
