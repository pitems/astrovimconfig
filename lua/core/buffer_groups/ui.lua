local M = {}

-- 📂 CREATE GROUP (handles your rules)
function M.create_group()
  local groups = require "core.buffer_groups.groups"
  local state = require "core.buffer_groups.state"
  local switch = require "core.buffer_groups.switch"

  vim.ui.input({ prompt = "Group name: " }, function(name)
    if not name or name == "" then
      vim.notify "ABORT: empty name"
      return
    end

    if state.groups[name] then
      vim.notify("Group already exists", vim.log.levels.WARN)
      return
    end
    local is_first = vim.tbl_isempty(state.groups)

    state.groups[name] = true

    -- groups.ensure_real_buffer()
    if is_first then
      groups.save_session(name)
    else
      vim.cmd "only"

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          local name = vim.api.nvim_buf_get_name(buf)
          if name ~= "" then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
        end
      end

      vim.cmd "enew"
      groups.save_session(name)
    end
    -- local path = vim.fn.getcwd() .. "/.nvim/sessions/" .. session .. ".vim"
    -- vim.notify("CHECK FILE: " .. path)

    switch.switch(name)
  end)
end

-- 🔄 SWITCH GROUP (UI)
function M.switch_group_ui()
  local switch = require "core.buffer_groups.switch"
  local state = require "core.buffer_groups.state"
  local resession = require "resession"

  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local conf = require("telescope.config").values
  local themes = require "telescope.themes"

  -- 🔥 get sessions from resession
  local sessions = resession.list { dir = "project" }

  local results = {}

  for _, name in ipairs(sessions) do
    if name:match "^bg_" then
      local clean = name:gsub("^bg_", "")

      local is_active = clean == state.active_group
      local icon = is_active and "● " or "󰆍 "

      table.insert(results, {
        display = icon .. clean,
        value = clean,
        ordinal = clean,
      })
    end
  end

  pickers
    .new(
      themes.get_dropdown {
        previewer = false,
        winblend = 10,
        layout_config = {
          width = 0.35,
          height = 0.25,
        },
      },
      {
        prompt_title = "Buffer Groups",

        finder = finders.new_table {
          results = results,
          entry_maker = function(entry)
            return {
              value = entry.value,
              display = entry.display,
              ordinal = entry.ordinal,
            }
          end,
        },

        sorter = conf.generic_sorter {},

        attach_mappings = function(_, map)
          map("i", "<CR>", function(bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(bufnr)

            if selection then switch.switch(selection.value) end
          end)

          return true
        end,
      }
    )
    :find()
end

-- ❌ CLOSE CURRENT GROUP
function M.close_current()
  local state = require "core.buffer_groups.state"
  local groups = require "core.buffer_groups.groups"
  local resession = require "resession"
  local switch = require "core.buffer_groups.switch"

  if not state.active_group then
    vim.notify("No active group", vim.log.levels.WARN)
    return
  end

  local current = state.active_group
  local session = groups.session_name(current)

  -- 🔥 delete session
  local ok, err = pcall(function() resession.delete(session, { dir = "project" }) end)

  if not ok then vim.notify("Delete failed: " .. err, vim.log.levels.ERROR) end

  -- 🔥 remove from state
  state.groups[current] = nil
  state.active_group = nil

  -- 🔍 get remaining groups from resession
  local sessions = resession.list { dir = "project" }

  local next_group = nil
  for _, name in ipairs(sessions) do
    if name:match "^bg_" then
      next_group = name:gsub("^bg_", "")
      break
    end
  end

  if next_group then
    vim.notify("Switching to: " .. next_group)
    switch.switch(next_group)
  else
    -- 🧼 no groups left
    vim.cmd "silent! %bd!"
    vim.cmd "enew"
    vim.cmd "only"
    vim.notify "Closed last group. Clean workspace."
  end
end

-- 🚪 EXIT GROUP MODE
function M.exit_all()
  local state = require "core.buffer_groups.state"
  local groups = require "core.buffer_groups.groups"
  local resession = require "resession"

  if state.active_group then
    pcall(resession.save, groups.session_name(state.active_group), {
      dir = "project", -- ✅ FIXED
    })
  end

  state.active_group = nil

  vim.notify "Exited group mode"
end

function M.rename_current()
  local state = require "core.buffer_groups.state"
  local groups = require "core.buffer_groups.groups"
  local resession = require "resession"

  if not state.active_group then
    vim.notify("No active group", vim.log.levels.WARN)
    return
  end

  local old_name = state.active_group

  vim.ui.input({ prompt = "New group name: " }, function(new_name)
    if not new_name or new_name == "" then return end

    local old_session = groups.session_name(old_name)
    local new_session = groups.session_name(new_name)

    -- ❌ prevent overwrite
    local sessions = resession.list { dir = "project" }
    for _, s in ipairs(sessions) do
      if s == new_session then
        vim.notify("Group already exists", vim.log.levels.WARN)
        return
      end
    end

    -- 💾 save under new name
    local ok, err = pcall(function() resession.save(new_session, { dir = "project" }) end)

    if not ok then
      vim.notify("Rename failed: " .. err, vim.log.levels.ERROR)
      return
    end

    -- 🗑 delete old
    pcall(function() resession.delete(old_session, { dir = "project" }) end)

    -- 🔄 update state
    state.groups[old_name] = nil
    state.groups[new_name] = true
    state.active_group = new_name

    vim.notify("Renamed group: " .. old_name .. " → " .. new_name)
  end)
end

-- 🎛 MENU
function M.open_menu()
  local options = {
    "Create Group",
    "Switch Group",
    "Rename Current Group",
    "Close Current Group",
    "Exit Group Mode",
  }

  vim.ui.select(options, {
    prompt = "Buffer Groups",
  }, function(choice)
    if not choice then return end

    if choice == "Create Group" then
      M.create_group()
    elseif choice == "Switch Group" then
      M.switch_group_ui()
    elseif choice == "Close Current Group" then
      M.close_current()
    elseif choice == "Rename Current Group" then
      M.rename_current()
    elseif choice == "Exit Group Mode" then
      M.exit_all()
    end
  end)
end

return M
