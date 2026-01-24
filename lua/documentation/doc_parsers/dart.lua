local function_finder = require("documentation.finders.function_finder")
local variable_finder = require('documentation.finders.variable_finder')
local M = {}
local METHOD_REGEX =
  "^%s*(?:[A-Za-z_<>,]+|void)%s+([A-Za-z_]\\w*)%s*%([^)]*%)%s*{?"

function M.parse_with_regex(bufnr, regex, opts)
  opts = opts or {}
  local want = opts.want -- "global" | "class" | "method"

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local results = {}

  local scope_depth = 0
  local inside_class = false
  local class_depth = nil

  local inside_method = false
  local method_depth = nil

  for row, line in ipairs(lines) do
    -- detect class start
    if not inside_class and line:match("^%s*class%s+%w+") then
      inside_class = true
      class_depth = scope_depth
    end

    -- detect method start (only inside class)
    if inside_class and not inside_method then
      if line:match(METHOD_REGEX) then
        inside_method = true
        method_depth = scope_depth
      end
    end

    -- matching rules
    local allow = false
    if want == "class" then
      allow = inside_class and not inside_method and scope_depth == class_depth + 1
    elseif want == "global" then
      allow = scope_depth == 0
    elseif want == "method" then
      allow = inside_method
    end

    if allow then
      local matches = { line:match(regex) }

      if #matches > 0 then
        table.insert(results, {
          captures = matches,
          row = row - 1,
          col = line:find(matches[#matches]) - 1,
          line = line,
        })
      end
    end

    -- update scope depth AFTER processing
    local open_braces = select(2, line:gsub("{", ""))
    local close_braces = select(2, line:gsub("}", ""))

    scope_depth = scope_depth + open_braces - close_braces

    -- exit method
    if inside_method and scope_depth <= method_depth then
      inside_method = false
      method_depth = nil
    end

    -- exit class
    if inside_class and scope_depth <= class_depth then
      inside_class = false
      class_depth = nil
    end
  end

  return results
end

-- public parser API
function M.parse(source_lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, source_lines)

  local functions = function_finder.find(buf, M.parse_with_regex)
  local variables = variable_finder.find(buf, M.parse_with_regex)
--   vim.notify(
--   "Variables:\n" .. vim.inspect(variables),
--   vim.log.levels.INFO,
--   { title = "Doc Parser" }
-- )
  vim.api.nvim_buf_delete(buf, { force = true })

  return {
    functions = functions,
    variables = variables,
  }
end

return M
