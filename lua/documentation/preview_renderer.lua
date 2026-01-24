local M = {}

function M.build(diff)
  local lines = {}

  if #diff.new > 0 then
    table.insert(lines, "➕ New functions:")
    for _, fn in ipairs(diff.new) do
      table.insert(lines, "  • " .. fn.name)
    end
    table.insert(lines, "")
  end

  if #diff.renamed > 0 then
    table.insert(lines, "🔁 Renamed functions:")
    for _, r in ipairs(diff.renamed) do
      table.insert(lines, "  • " .. r.from .. " → " .. r.to)
    end
    table.insert(lines, "")
  end

  if #diff.removed > 0 then
    table.insert(lines, "⚠️ Deprecated functions:")
    for _, fn in ipairs(diff.removed) do
      table.insert(lines, "  • " .. fn.name)
    end
  end

  return lines
end

return M
