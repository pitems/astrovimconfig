local M = {}

-- import '...';
local IMPORT_REGEX = "^%s*import%s+['\"]([^'\"]+)['\"];"

-- read package name from pubspec.yaml
local function get_package_name(start_path)
  local dir = vim.fs.dirname(start_path)

  while dir do
    local pubspec = dir .. "/pubspec.yaml"
    if vim.fn.filereadable(pubspec) == 1 then
      for _, line in ipairs(vim.fn.readfile(pubspec)) do
        local name = line:match("^name:%s*(%S+)")
        if name then
          return name
        end
      end
    end
    dir = vim.fs.dirname(dir)
  end

  return nil
end

function M.find(bufnr)
  local deps = {}
  local file = vim.api.nvim_buf_get_name(bufnr)
  local package = get_package_name(file)

  if not package then
    return deps
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for row, line in ipairs(lines) do
    local import = line:match(IMPORT_REGEX)
    if import then
      -- keep only local package imports
      local prefix = "package:" .. package .. "/"
      if import:find(prefix, 1, true) == 1 then
        local path = import:gsub("^" .. prefix, "")

        table.insert(deps, {
          import = import,
          package = package,
          path = path,
          row = row - 1,
          kind = "dependency",
        })
      end
    end
  end

  return deps
end

return M
