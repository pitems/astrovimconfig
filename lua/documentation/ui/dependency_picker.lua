local has_telescope, pickers = pcall(require, "telescope.pickers")
if not has_telescope then return end
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

-- documentation folder at root of current project
local DOCS_ROOT = vim.fn.getcwd() .. "/documentation"

--- Converts Dart-style import path to documentation path
local function import_to_doc_path(dep)
  -- remove package prefix if it exists
  local path = dep:gsub("^package:app_empresas/", "")
  -- replace slashes and add .md
  local doc_path = DOCS_ROOT .. "/" .. path:gsub("%.dart$", "") .. ".md"
  return doc_path
end

function M.show_dependencies(dependencies)
  pickers.new({}, {
    prompt_title = "Dependencies",
    finder = finders.new_table({
      results = dependencies,
      entry_maker = function(dep)
        local doc_path = import_to_doc_path(dep)
        local exists = vim.fn.filereadable(doc_path) == 1

        return {
          value = dep,
          display = function()
            local status_icon = exists and "✔" or "✖"
            local display_str = dep .. " " .. status_icon
            -- color the status icon
            if exists then
              return display_str
            else
              return display_str
            end
          end,
          ordinal = dep,
          exists = exists,
          doc_path = doc_path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection.exists then
          vim.cmd("edit " .. selection.doc_path)
        else
          vim.notify("No documentation found for this dependency", vim.log.levels.WARN)
        end
        actions.close(prompt_bufnr)
      end)
      return true
    end,
  }):find()
end

return M
