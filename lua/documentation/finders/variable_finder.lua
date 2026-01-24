-- documentation/finders/variable_finder.lua
local M = {}

-- Regexes for different variable patterns
local VARIABLE_REGEXES = {
  -- 1️⃣ Modifier + primitive type
  "^%s*(final|const|static|late)%s+(int)%s+(%w+)%s*=",
  "^%s*(final|const|static|late)%s+(double)%s+(%w+)%s*=",
  "^%s*(final|const|static|late)%s+(num)%s+(%w+)%s*=",
  "^%s*(final|const|static|late)%s+(bool)%s+(%w+)%s*=",
  "^%s*(final|const|static|late)%s+(String)%s+(%w+)%s*=",
  "^%s*(final|const|static|late)%s+(dynamic)%s+(%w+)%s*=",

  -- 2️⃣ Primitive type without modifier
  "^%s*(int)%s+(%w+)%s*=",
  "^%s*(double)%s+(%w+)%s*=",
  "^%s*(num)%s+(%w+)%s*=",
  "^%s*(bool)%s+(%w+)%s*=",
  "^%s*(String)%s+(%w+)%s*=",
  "^%s*(dynamic)%s+(%w+)%s*=",

  -- 3️⃣ Modifier + object type (e.g., List<Something>)
  "^%s*(final|const|static|late)%s+([A-Z][%w<>?, ]*)%s+(%w+)%s*=",

  -- 4️⃣ Object type without modifier (catch-all)
  "^%s*([A-Z][%w<>?, ]*)%s+(%w+)%s*=",

  -- 5️⃣ var / const shorthand
  "^%s*var%s+(%w+)%s*=",
  "^%s*const%s+(%w+)%s*=",

  -- 6️⃣ Modifier only (type inferred / dynamic)
  "^%s*(final|const|static|late)%s+(%w+)%s*="
}

function M.find(bufnr, parse_with_regex)
  local vars = {}
  local DEBUG = true -- toggle this

  -- Read each line once
  for line_num = 1, vim.api.nvim_buf_line_count(bufnr) do
    local line = vim.api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)[1]

    if not line or line == "" then
      goto continue_line
    end

    local matched = false

    for _, regex in ipairs(VARIABLE_REGEXES) do
      local captures = { string.match(line, regex) }
      if #captures > 0 then
        local modifier, type_, name

        if #captures == 3 then
          modifier = captures[1]
          type_    = captures[2]
          name     = captures[3]
        elseif #captures == 2 then
          type_ = captures[1]
          name  = captures[2]
        elseif #captures == 1 then
          name  = captures[1]
          type_ = "dynamic"
        end

        if not name or name == "" then
          if DEBUG then
            vim.notify(
              "Skipping variable with nil name:\nLine " .. line_num .. ": " .. line,
              vim.log.levels.WARN
            )
          end
          goto continue_regex
        end

        table.insert(vars, {
          name     = name,
          type     = type_ or "dynamic",
          modifier = modifier,
          row      = line_num,
          col      = 1,
          kind     = "variable",
        })

        if DEBUG then
          vim.notify(
            string.format(
              "Matched variable:\n  Regex: %s\n  Name: %s\n  Type: %s\n  Modifier: %s\n  Line: %d",
              regex, name, type_, modifier or "", line_num
            ),
            vim.log.levels.INFO
          )
        end

        matched = true
        break -- ✅ Stop after the first matching regex
      end

      ::continue_regex::
    end

    ::continue_line::
  end

  return vars
end

return M
