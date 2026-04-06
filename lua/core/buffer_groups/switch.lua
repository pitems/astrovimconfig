local state = require "core.buffer_groups.state"
local groups = require "core.buffer_groups.groups"
local resession = require "resession"

local M = {}

function M.switch(group_name)
  local current = state.active_group

  -- 💾 save current
  if current and current ~= group_name then groups.save_session(current) end

  state.active_group = group_name

  local session = groups.session_name(group_name)

  -- 🔄 load from SAME dir
  local ok = pcall(resession.load, session, {
    dir = "project",
  })

  if not ok then vim.notify("Session not found: " .. group_name, vim.log.levels.WARN) end

  vim.cmd "redrawtabline"
  vim.notify("Switched to group: " .. group_name)
end

return M
