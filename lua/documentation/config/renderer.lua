local headers = require("documentation.config.headers")

local M = {}

-- ---- section renderers ------------------------------------

local function render_functions(functions)
  local md = {}
    for _, fn in ipairs(functions) do
      if not fn.name then
        vim.notify(
          "Skipping function with nil name:\n" .. vim.inspect(fn),
          vim.log.levels.WARN
        )
        goto continue
      end

      local return_type = fn.return_type or ""
      table.insert(md, "")
      table.insert(md, "### " .. return_type .. " " .. fn.name .. "()")
      table.insert(md, "")
      table.insert(md, "_TODO: describe behavior_")

      ::continue::
    end

  return md
end


-- ---- variable renderer ------------------------------------
local function render_variables(vars)
  local md = {}
  local groups = {}

  -- group by type
  for _, v in ipairs(vars) do
    local t = v.type or "unknown"
    groups[t] = groups[t] or {}
    table.insert(groups[t], v)
  end

  -- stable ordering
  local ordered_types = {}
  for t in pairs(groups) do
    table.insert(ordered_types, t)
  end
  table.sort(ordered_types)

  -- render
  for _, t in ipairs(ordered_types) do
    table.insert(md, "")
    table.insert(md, "### " .. t)
    table.insert(md, "")

    for _, v in ipairs(groups[t]) do
      -- 🔧 THIS IS THE FIX
      local label = table.concat(
        vim.tbl_filter(function(x) return x end, {
          v.modifier,
          v.type,
          v.name,
        }),
        " "
      )

      table.insert(md, "- **" .. label .. "**  ")
      table.insert(md, "  _TODO: describe variable_")
      table.insert(md, "")
    end
  end

  return md
end


-- ---- renderer list ---------------------------------------
local renderers = {
  render_functions = render_functions,
  render_variables = render_variables,
}

-- ---- public API -------------------------------------------

function M.build(rel_path, parsed)
  local md = {
    "# Documentation: " .. rel_path,
    "",
    "## Overview",
    "",
  }

  for _, section in pairs(headers.sections) do
    local items = parsed[section.key]

    if items and #items > 0 then
      table.insert(md, "")
      table.insert(
        md,
        string.format(
          "## %s %s (%d)",
          section.icon,
          section.title,
          #items
        )
      )

      local renderer = renderers[section.renderer]
      if renderer then
        vim.list_extend(md, renderer(items))
      end
    end
  end

  return md
end

-- used when *updating* docs (adding only new blocks)
function M.render_section(section_key, items)
  for _, section in pairs(headers.sections) do
    if section.key == section_key then
      local renderer = renderers[section.renderer]
      return renderer and renderer(items) or {}
    end
  end
  return {}
end

return M
