local dart_parser = require("documentation.doc_parsers.dart")

local M = {}

-- VERY IMPORTANT:
-- this regex CAPTURES ONLY THE VARIABLE NAME
local VARIABLE_REGEX =
  "%f[%w](?:final|var|const|int|double|String|bool|List<.*>|Map<.*>)%s+(%w+)"

function M.find(bufnr)
  local raw = dart_parser.parse_with_regex(bufnr, VARIABLE_REGEX)
  local vars = {}

  for _, item in ipairs(raw) do
    table.insert(vars, {
      name = item.name,
      row = item.row,
      col = item.col,
      kind = "variable",
    })
  end

  return vars
end

return M
