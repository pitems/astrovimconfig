local parsers = require("utils.doc_parsers")
local utils  = require('utils.documents_utils')
local M = {}

function M.open_or_create_doc()
  local source_buf = vim.api.nvim_get_current_buf()
  local source_path = vim.api.nvim_buf_get_name(source_buf)
  if source_path == "" then return end

  local project_root = vim.fn.getcwd()
  local rel = source_path:gsub(project_root .. "/", "")
  local doc_path = project_root
    .. "/documentation/"
    .. rel:gsub("%.%w+$", ".md")

  local filetype = vim.bo[source_buf].filetype
  local parser = parsers.get(filetype)

  local source_lines =
    vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)

  -- 📄 DOC EXISTS
  if vim.loop.fs_stat(doc_path) then
    vim.cmd("edit " .. doc_path)

    if not parser then return end

    local md_lines =
      vim.api.nvim_buf_get_lines(0, 0, -1, false)

    local documented = utils.extract_documented_functions(md_lines)
    local functions = parser.extract_functions(source_lines)
    local diff = utils.compute_diff(documented,functions)
    if #diff.new == 0 and #diff.removed == 0 then
      return
    end
    local preview = {}

    if #diff.new > 0 then
      for _, fn in ipairs(diff.new) do
        assert(fn.name, "diff.new contains invalid entries")
      end
      table.insert(preview, "➕ New functions:")
      for _, fn in ipairs(diff.new) do
        table.insert(preview, "  • " .. fn.name)
      end
    end

    if #diff.renamed > 0 then
      table.insert(preview, "🔁 Renamed functions:")
      for _, r in ipairs(diff.renamed) do
        table.insert(preview, "  • " .. r.from .. " → " .. r.to)
      end
    end

    if #diff.removed > 0 then
      table.insert(preview, "⚠️ Deprecated functions:")
      for _, fn in ipairs(diff.removed) do
        table.insert(preview, "  • " .. fn.name)
      end
    end

    if #preview == 0 then
      return
    end

    vim.ui.select(
      { "Apply Changes", "Cancel" },
      {
        prompt = "Documentation changes detected\n\n" .. table.concat(preview, "\n"),
      },
      function(choice)
        if choice ~= "Apply Changes" then return end

        -- Work on md_lines ONLY
        local updated = vim.deepcopy(md_lines)
        vim.notify(vim.inspect(diff.renamed))
        -- 1️⃣ Add new functions
        if #diff.new > 0 then
          local blocks = parser.render_function_blocks(diff.new)
          for _, line in ipairs(blocks) do
            table.insert(updated, line)
          end
        end

        if #diff.renamed > 0 then
          utils.apply_renames_inline(updated, diff.renamed)
        end

        -- 2️⃣ Mark deprecated
        if #diff.removed > 0 then
          utils.mark_deprecated_inline(updated, diff.removed,diff.renamed)
        end

        -- 🔥 Single write, no clobbering
        vim.api.nvim_buf_set_lines(0, 0, -1, false, updated)
      end
    )
    return
  end

  -- 🆕 DOC DOES NOT EXIST
  vim.ui.select(
    { "Yes", "No" },
    { prompt = "Create documentation file?" },
    function(choice)
      if choice ~= "Yes" then return end

      local md_lines

      if parser then
        local functions = parser.extract_functions(source_lines)
        md_lines = parser.render_md(rel, functions)
      else
        md_lines = {
          "# Documentation: " .. rel,
          "",
          "## Overview",
          "",
          "## Notes",
        }
      end

      vim.fn.mkdir(vim.fn.fnamemodify(doc_path, ":h"), "p")
      vim.cmd("edit " .. doc_path)
      vim.api.nvim_buf_set_lines(0, 0, -1, false, md_lines)
    end
  )
end

return M
