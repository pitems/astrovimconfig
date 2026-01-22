local utils = require('utils.documents_utils')
local parser = require('utils.doc_parsers')
local M= {}

function M.sync_documentation(doc_path, source_lines)
  -- parse
  local documented = utils.extract_documented_functions(md_lines)
  local functions = parser.extract_functions(source_lines)

  local diff = utils.compute_diff(documented, functions)

  if #diff.new == 0 and #diff.removed == 0 then
    return
  end

  local actions = {}

  if #diff.new > 0 then
    table.insert(actions, {
      label = "➕ Add new functions (" .. #diff.new .. ")",
      apply = function()
        local blocks = parser.render_function_blocks(diff.new)
        vim.api.nvim_buf_set_lines(0, -1, -1, false, blocks)
      end
    })
  end

  if #diff.removed > 0 then
    table.insert(actions, {
      label = "⚠️ Mark removed as deprecated (" .. #diff.removed .. ")",
      apply = function()
        utils.mark_deprecated_inline(md_lines, diff.removed)
        vim.api.nvim_buf_set_lines(0, 0, -1, false, md_lines)
      end
    })
  end

  vim.ui.select(
    vim.tbl_map(function(a) return a.label end, actions),
    { prompt = "Documentation changes detected" },
    function(choice)
      if not choice then return end
      for _, action in ipairs(actions) do
        if action.label == choice then
          action.apply()
          break
        end
      end
    end
  )
end

return M
