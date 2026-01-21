local M = {}

function M.extract_functions(lines)
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

  return functions
end

function M.render_md(rel_path, functions)
  local md = {
    "# Documentation: " .. rel_path,
    "",
    "## Overview",
    "",
    "## Functions",
  }
  vim.list_extend(md,M.render_function_blocks(functions))
  return md
end

function M.render_function_blocks(functions)
  local md = {}

  for _, fn in ipairs(functions) do
    table.insert(md, "")
    table.insert(md, "### " .. fn.return_type .. " " .. fn.name .. "()")
    table.insert(md, "")
    table.insert(md, "_TODO: describe behavior_")
  end

  return md
end

return M
