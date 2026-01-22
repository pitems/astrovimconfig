local M = {}


local function extract_fn_name(line)
  return line:match("^### .+ (%w+)%(")
end

function M.extract_documented_functions(md_lines)
  local documented = {}

  for _, line in ipairs(md_lines) do
    local return_type, name =
      line:match("^###%s+(.-)%s+(%w+)%(")

    if name then
      documented[name] = {
        return_type = return_type,
        deprecated = line:find("Deprecated") ~= nil,
      }
    end
  end

  return documented
end

function M.find_new_functions(current_functions, documented)
  local out = {}

  for _, fn in ipairs(current_functions) do
    if not documented[fn.name] then
      table.insert(out, fn)
    end
  end

  return out
end

function M.find_removed_functions(documented, current_functions)
  local current = {}
  for _, fn in ipairs(current_functions) do
    current[fn.name] = true
  end

  local removed = {}
  for name, meta in pairs(documented) do
    if not current[name] and not meta.deprecated then
      table.insert(removed, {
        name = name,
        return_type = meta.return_type,
      })
    end
  end

  return removed
end


function M.mark_deprecated_inline(lines, removed, renamed)
  local removed_map = {}
  for _, fn in ipairs(removed) do
    removed_map[fn.name] = true
  end

  local renamed_from = {}
  for _, r in ipairs(renamed) do
    renamed_from[r.from] = true
  end

  for i = #lines, 1, -1 do
    local name = extract_fn_name(lines[i])
    if
      name
      and removed_map[name]
      and not renamed_from[name]
      and not lines[i]:find("Deprecated")
    then
      lines[i] = lines[i] .. " ⚠️ Deprecated"
      table.insert(lines, i + 1, "")
      table.insert(lines, i + 2, "_Removed from source code_")
    end
  end
end


function M.apply_renames_inline(lines, renamed)
  local renamed_map = {}
  for _, r in ipairs(renamed) do
    renamed_map[r.from] = r.to
  end

  for i, line in ipairs(lines) do
    local name = extract_fn_name(line)
    local to = renamed_map[name]

    if to then
      lines[i] = line:gsub(
        name,
        to,
        1
      )
      table.insert(lines, i + 1, "> Renamed from `" .. name .. "`")
    end
  end
end


function M.compute_diff(documented, current, renames)
  local valid_renames = {}
  local renamed_from = {}
  local renamed_to = {}

  for _, r in ipairs(renames or {}) do
    if documented[r.from] then
      table.insert(valid_renames, r)
      renamed_from[r.from] = true
      renamed_to[r.to] = true
    end
  end

  local new = {}
  for _, fn in ipairs(current) do
    if not documented[fn.name] and not renamed_to[fn.name] then
      table.insert(new, fn)
    end
  end

  local removed = {}
  for name, meta in pairs(documented) do
    if
      not meta.deprecated
      and not renamed_from[name]
      and not vim.tbl_contains(
        vim.tbl_map(function(f) return f.name end, current),
        name
      )
    then
      table.insert(removed, { name = name })
    end
  end

  return {
    new = new,
    removed = removed,
    renamed = valid_renames,
  }
end

return M
