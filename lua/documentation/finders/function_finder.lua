local M = {}

-- return-type + name
local FUNCTION_REGEXES = {
  -- return-type + name (...) async
  "^%s*([A-Z][%w<>?, ]*)%s+([%w_]+)%s*%([^)]*%)%s*async%s*{",

  -- return-type + name (...)
  "^%s*([A-Z][%w<>?, ]*)%s+([%w_]+)%s*%([^)]*%)%s*{",

  -- void functions
  "^%s*void%s+([%w_]+)%s*%([^)]*%)%s*async%s*{",
  "^%s*void%s+([%w_]+)%s*%([^)]*%)%s*{",

  -- NO return type (VERY IMPORTANT)
  "^%s*([%w_]+)%s*%([^)]*%)%s*async%s*{",
  "^%s*([%w_]+)%s*%([^)]*%)%s*{",

  -- arrow functions
  "^%s*([A-Z][%w<>?, ]*)%s+([%w_]+)%s*%([^)]*%)%s*=>",
  "^%s*([%w_]+)%s*%([^)]*%)%s*=>",

  -- getters / setters
  "^%s*get%s+([%w_]+)%s*%(",
  "^%s*set%s+([%w_]+)%s*%(",
}

function M.find(bufnr, parse_with_regex)
  local results = {}
  local DEBUG = false

  for _, regex in ipairs(FUNCTION_REGEXES) do
    local raw = parse_with_regex(bufnr, regex, { want = "class" }) or {}

    if DEBUG and #raw > 0 then
      vim.notify(
        "FUNCTION REGEX MATCH:\n"
          .. regex
          .. "\n"
          .. vim.inspect(raw),
        vim.log.levels.INFO
      )
    end

    for _, item in ipairs(raw) do
      local caps = item.captures or {}

      local return_type, name

      if #caps == 2 then
        -- ReturnType name
        return_type = caps[1]
        name        = caps[2]

      elseif #caps == 1 then
        -- void foo / getter / setter
        name        = caps[1]
        return_type = "void"
      end

      if not name or name == "" then
        if DEBUG then
          vim.notify(
            "Skipping function with nil name:\n" .. vim.inspect(item),
            vim.log.levels.WARN
          )
        end
        goto continue
      end

      table.insert(results, {
        name        = name,
        return_type = return_type or "dynamic",
        row         = item.row,
        kind        = "function",
      })

      ::continue::
    end
  end

  return results
end

return M
