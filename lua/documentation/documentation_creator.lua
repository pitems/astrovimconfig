local parsers = require("documentation.doc_parsers.init")
local utils  = require('documentation.documents_utils')
local renderer = require('documentation.config.renderer')
local preview_renderer = require('documentation.preview_renderer')
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
    local parsed = parser.parse(source_lines)
    local functions = parsed.functions

    local rename = require("documentation.rename")

    local renames = rename.detect_renames(source_path)
    

    local diff = utils.compute_diff(documented,functions,renames)
    if #diff.new == 0 and #diff.removed == 0 and #diff.renamed == 0 then
      return
    end
    
    local modalpreview = require('documentation.ui.changes_preview')
    modalpreview.open(diff,function()
        -- Work on md_lines ONLY
        local updated = vim.deepcopy(md_lines)
        -- 1️⃣ Add new functions
        if #diff.new > 0 then
          local blocks = renderer.render_section('functions',diff.new)
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
        local functions = parser.parse(source_lines)
        md_lines = renderer.build(rel, functions)
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
