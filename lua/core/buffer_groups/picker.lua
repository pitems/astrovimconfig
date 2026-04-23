local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local previewers = require "telescope.previewers"

local resession = require "resession"
local ui = require "core.buffer_groups.ui"
local groups = require "core.buffer_groups.groups"
local switch = require "core.buffer_groups.switch"
local state = require "core.buffer_groups.state"

-- Build entries like the old picker
local function get_entries_old_style()
  local sessions = resession.list { dir = "project" }
  local entries = {}

  for _, name in ipairs(sessions) do
    if name:match "^bg_" then
      local clean = name:gsub("^bg_", "")
      local is_active = clean == state.active_group
      local icon = is_active and " " or "󰆍 "

      table.insert(entries, {
        value = clean,
        display = icon .. clean,
        ordinal = clean,
        is_active = is_active, -- flag to sort
      })
    end
  end

  -- Sort: active group always first
  table.sort(entries, function(a, b)
    if a.is_active then return true end
    if b.is_active then return false end
    return a.ordinal < b.ordinal
  end)

  return entries
end

-- Footer display (keybinds)
local function footer_display()
  local keys = "c: create   r: rename   d: delete   e: exit"
  return keys
end

function M.open_picker2()
  local entries = get_entries_old_style()
  if vim.tbl_isempty(entries) then
    vim.notify("No buffer groups found", vim.log.levels.INFO)
    ui.create_group()
    return
  end

  pickers
    .new({
      prompt_title = "Buffer Groups",
      -- results_title = "Keymaps: [c]reate [r]ename [d]elete [e]xit | <CR> switch",
      layout_strategy = "horizontal",
      layout_config = {
        width = 0.9,
        height = 0.6,
        prompt_position = "top",
        preview_width = 0.5,
        mirror = false,
      },
    }, {
      finder = finders.new_table {
        results = entries,
        entry_maker = function(entry)
          return {
            value = entry.value,
            display = entry.display,
            ordinal = entry.ordinal,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = previewers.new_buffer_previewer {
        define_preview = function(self, entry, status)
          local bufs = groups.get_buffers(entry.value) or {}
          -- inside previewer define_preview
          local lines = {
            "Keybinds: [c]reate [r]ename [d]elete [e]xit | <CR> switch",
            string.rep("─", 80),
            "Buffers:",
          }
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

          local ns = vim.api.nvim_create_namespace "buffer_group_preview"
          local bufnr = self.state.bufnr
          local line = 0 -- first line (0-indexed)

          -- Keybinds: [c]reate [r]ename [d]elete [e]xit | <CR> switch
          local highlights = {
            { start = 10, finish = 11 }, -- [c]
            { start = 18, finish = 19 }, -- [r]
            { start = 26, finish = 27 }, -- [d]
            { start = 34, finish = 37 }, -- <CR>
          }

          for _, hl in ipairs(highlights) do
            vim.hl.range(
              bufnr,
              ns,
              "Keyword", -- highlight group
              { line, hl.start }, -- start position
              { line, hl.finish }, -- end position
              { inclusive = false } -- optional, default false
            )
          end
          if vim.tbl_isempty(bufs) then
            table.insert(lines, "  <No buffers>")
          else
            for _, buf in ipairs(bufs) do
              table.insert(lines, "  " .. buf)
            end
          end

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        end,
      },
      attach_mappings = function(prompt_bufnr, map)
        local function close_picker_and(fn)
          local selection = action_state.get_selected_entry()
          -- schedule the function to run after Telescope closes
          vim.schedule(function()
            if fn then
              if selection then
                fn(selection.value)
              else
                fn()
              end
            end
          end)
          actions.close(prompt_bufnr)
        end

        -- Switch to group
        map("i", "<CR>", function() close_picker_and(switch.switch) end)

        -- Create new group
        map("i", "c", function() close_picker_and(ui.create_group) end)

        -- Rename current group
        map("i", "r", function() close_picker_and(ui.rename_current) end)

        -- Delete current group
        map("i", "d", function() close_picker_and(ui.close_current) end)

        -- Exit all groups
        map("i", "e", function() close_picker_and(ui.exit_all_with_confirm()) end)

        return true
      end,
      sorting_strategy = "ascending",
      entry_display = {
        bottom_line = function() return footer_display() end,
      },
    })
    :find()
end

return M
