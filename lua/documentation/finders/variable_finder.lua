-- documentation/finders/variable_finder.lua
local M = {}

local VARIABLE_REGEXES = {
  -- modifier + Type + name =
  "^%s*(final|const|static|late)%s+([A-Z][%w<>?, ]*)%s+(%w+)%s*=",

  -- modifier + name (type inferred / dynamic)
  "^%s*(final|const|static|late)%s+(%w+)%s*=",

  -- var / const shorthand
  "^%s*var%s+(%w+)%s*=",
  "^%s*const%s+(%w+)%s*=",

  -- primitives
  "^%s*int%s+(%w+)%s*=",
  "^%s*double%s+(%w+)%s*=",
  "^%s*num%s+(%w+)%s*=",
  "^%s*bool%s+(%w+)%s*=",
  "^%s*String%s+(%w+)%s*=",
  "^%s*dynamic%s+(%w+)%s*=",

  -- object without modifier
  "^%s*([A-Z][%w<>?, ]*)%s+(%w+)%s*="
}

function M.find(bufnr, parse_with_regex)
  local vars = {}
  local DEBUG = true -- toggle this

  for _, regex in ipairs(VARIABLE_REGEXES) do
    local raw = parse_with_regex(bufnr, regex, { want = "class" }) or {}

    for _, item in ipairs(raw) do
      local caps = item.captures or {}

      local modifier, type_, name

      if #caps == 3 then
        modifier = caps[1]
        type_    = caps[2]
        name     = caps[3]

      elseif #caps == 2 then
        type_ = caps[1]
        name  = caps[2]

      elseif #caps == 1 then
        name  = caps[1]
        type_ = "dynamic"
      end

      -- 🚑 DO NOT ALLOW INVALID VARS
      if not name or name == "" then
        if DEBUG then
          vim.notify(
            "Skipping variable with nil name:\n" .. vim.inspect(item),
            vim.log.levels.WARN
          )
        end
        goto continue
      end

      table.insert(vars, {
        name     = name,
        type     = type_ or "unknown",
        modifier = modifier,
        row      = item.row,
        col      = item.col,
        kind     = "variable",
      })

      ::continue::
    end
  end

  return vars
end

return M
