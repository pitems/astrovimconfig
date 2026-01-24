local headers = require("documentation.config.headers")

local M = {}

-- ---- section renderers ------------------------------------

local function render_functions(functions)
  local md = {}

  for _, fn in ipairs(functions) do
    table.insert(md, "")
    table.insert(md, "### " .. fn.return_type .. " " .. fn.name .. "()")
    table.insert(md, "")
    table.insert(md, "_TODO: describe behavior_")
  end

  return md
end

local renderers = {
  render_functions = render_functions,
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
