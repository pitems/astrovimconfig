-- ~/.config/nvim/lua/user/tabsession.lua
local M = {}
local resession = require("resession")
local Path = require("plenary.path")

-- Store sessions with prefix "tab_" to distinguish
local function get_tab_name()
  return vim.fn.input("Tab session name: ")
end

function M.save_current_tab()
  local name = get_tab_name()
  if name ~= "" then
    resession.save("tab_" .. name, { notify = true })
  end
end

function M.load_tab()
  local sessions = resession.list()
  local tab_sessions = {}
  for _, name in ipairs(sessions) do
    if name:match("^tab_") then
      table.insert(tab_sessions, name)
    end
  end

  vim.ui.select(tab_sessions, { prompt = "Select tab session:" }, function(choice)
    if choice then
      vim.cmd("tabnew")
      resession.load(choice, { reset = true })
    end
  end)
end

function M.delete_current_tab()
  local name = get_tab_name()
  if name ~= "" then
    local path = Path:new(resession.get_session_file("tab_" .. name))
    if path:exists() then
      path:rm()
      vim.notify("Deleted session: tab_" .. name)
    else
      vim.notify("Session not found!", vim.log.levels.WARN)
    end
  end
end

return M
