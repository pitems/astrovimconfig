local M = {}

local function levenshtein(a, b)
  if a == b then return 0 end
  if #a == 0 then return #b end
  if #b == 0 then return #a end

  local matrix = {}

  for i = 0, #a do
    matrix[i] = {[0] = i}
  end
  for j = 0, #b do
    matrix[0][j] = j
  end

  for i = 1, #a do
    for j = 1, #b do
      local cost = a:sub(i,i) == b:sub(j,j) and 0 or 1
      matrix[i][j] = math.min(
        matrix[i-1][j] + 1,
        matrix[i][j-1] + 1,
        matrix[i-1][j-1] + cost
      )
    end
  end

  return matrix[#a][#b]
end

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

function M.detect_renames(removed, new)
  local renamed = {}
  local used_new = {}
  local used_removed = {}

  for i, old in ipairs(removed) do
    local best, best_idx, best_score

    for j, fn in ipairs(new) do
      if not used_new[j]
        and fn.return_type == old.return_type then

        local d = levenshtein(old.name, fn.name)
        local score = 1 - (d / math.max(#old.name, #fn.name))

        if score > 0.5 and (not best or score > best_score) then
          best = fn
          best_idx = j
          best_score = score
        end
      end
    end

    if best then
      used_new[best_idx] = true
      used_removed[i] = true
      table.insert(renamed, {
        from = old.name,
        to = best.name,
      })
    end
  end

  return renamed, used_removed, used_new
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


function M.compute_diff(documented, current)
  local new = M.find_new_functions(current, documented)
  local removed = M.find_removed_functions(documented, current)

  local renamed, used_removed, used_new =
    M.detect_renames(removed, new)

  local final_new = {}
  for i, fn in ipairs(new) do
    if not used_new[i] then
      table.insert(final_new, fn)
    end
  end

  local final_removed = {}
  for i, name in ipairs(removed) do
    if not used_removed[i] then
      table.insert(final_removed, name)
    end
  end

  vim.notify(vim.inspect({
  new = new,
  removed = removed,
  renamed = renamed,
}))


  return {
    new = final_new,
    removed = final_removed,
    renamed = renamed,
  }
end

return M
