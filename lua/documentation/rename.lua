-- rename.lua
local M = {}

local function run(cmd)
  local handle = io.popen(cmd)
  if not handle then return "" end
  local result = handle:read("*a")
  handle:close()
  return result
end

local function git_merge_base(branch)
  local cmd = string.format(
    "git merge-base HEAD %s 2>/dev/null",
    branch
  )
  local base = run(cmd):gsub("%s+", "")
  if base == "" then
    return nil
  end
  return base
end


function M.detect_renames(source_path)

 opts = opts or {}
  local baseline = opts.baseline_branch or "main"

  -- 1️⃣ First: current behavior (working tree vs HEAD)
  local cmd = string.format(
    "git diff -M -U0 HEAD -- %q",
    source_path
  )

  local diff = run(cmd)

  -- 2️⃣ Fallback: compare against merge-base if nothing found
  if diff == "" then
    local base = git_merge_base(baseline)
    if base then
      cmd = string.format(
        "git diff -M -U0 %s..HEAD -- %q",
        base,
        source_path
      )
      diff = run(cmd)
    end
  end

  local diff = run(cmd)
  if diff == "" then return {} end

  local removed = {}
  local added = {}

  for line in diff:gmatch("[^\n]+") do
    -- very simple Dart example
    local old = line:match("^%-.* (%w+)%(")
    if old then
      table.insert(removed, old)
    end

    local new = line:match("^%+.* (%w+)%(")
    if new then
      table.insert(added, new)
    end
  end

  local renames = {}

  -- naive pairing (good enough to start)
  for i = 1, math.min(#removed, #added) do
    if removed[i] ~= added[i] then
      table.insert(renames, {
        from = removed[i],
        to = added[i],
      })
    end
  end

  return renames
end

-- rename local check
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

function M.old_detect_renames(removed, new)
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


return M
