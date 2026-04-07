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

    -- 💾 save current BEFORE doing anything
    if state.active_group then groups.save_session(state.active_group) end

    -- register
    state.groups[name] = true

    local is_first = not state.active_group

    if is_first then
      -- 🧠 first group = clone current workspace
      groups.save_session(name)
      switch.switch(name)
      return
    end

    -- 🔥 IMPORTANT: create empty session WITHOUT touching current workspace
    groups.save_session(name)

    -- 🔄 switch FIRST
    switch.switch(name)

    -- 🧼 NOW we are inside new group → safe to clean
    vim.schedule(function()
      vim.cmd "only"

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          local bufname = vim.api.nvim_buf_get_name(buf)
          if bufname ~= "" then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
        end
      end

      vim.cmd "enew"

      -- 💾 save empty state
      groups.save_session(name)
    end)
  end)
end

-- 🎛 MENU
function M.open_picker()
  local state = require "core.buffer_groups.state"
  local switch = require "core.buffer_groups.switch"
  local resession = require "resession"

  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local conf = require("telescope.config").values
  local themes = require "telescope.themes"

  local in_group = state.active_group ~= nil

  local sessions = resession.list { dir = "project" }

  local entries = {}

  -- 🟡 NOT in group mode

  -- 🔵 existing groups
  for _, name in ipairs(sessions) do
    if name:match "^bg_" then
      local clean = name:gsub("^bg_", "")

      local is_active = clean == state.active_group
      local icon = is_active and "● " or "󰆍 "

      table.insert(entries, {
        display = icon .. clean,
        value = clean,
        ordinal = "1_" .. clean,
      })
    end
  end

  -- 🟢 always available
  table.insert(entries, {
    display = "➕ Create Group",
    value = "__create__",
    ordinal = "2_create",
  })

  -- 🔴 only in group mode
  if in_group then
    table.insert(entries, {
      display = "✏ Rename Current Group",
      value = "__rename__",
      ordinal = "3_rename",
    })

    table.insert(entries, {
      display = "🗑 Delete Current Group",
      value = "__delete__",
      ordinal = "4_delete",
    })

    table.insert(entries, {
      display = "⏻ Exit Group Mode",
      value = "__exit__",
      ordinal = "5_exit",
    })
  end

  pickers
    .new(
      themes.get_dropdown {
        previewer = false,
        winblend = 10,
        layout_config = {
          width = 0.35,
          height = 0.3,
        },
      },
      {
        prompt_title = "Buffer Groups",

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

        attach_mappings = function(_, map)
          map("i", "<CR>", function(bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(bufnr)

            if not selection then return end

            local value = selection.value

            if value == "__create__" then
              M.create_group()
            elseif value == "__rename__" then
              M.rename_current()
            elseif value == "__delete__" then
              M.close_current()
            elseif value == "__exit__" then
              M.exit_all()
            elseif value == "__start__" then
              -- do nothing (UX only)
              return
            else
              -- 🔥 real group
              switch.switch(value)
            end
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

return M
