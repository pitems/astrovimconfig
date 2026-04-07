local M = {}

local session_dir = "project"

local debug = false

function M.ensure_session_dir()
  if vim.fn.isdirectory(session_dir) == 0 then vim.fn.mkdir(session_dir, "p") end
end

function M.session_name(name) return "bg_" .. name end

function M.session_dir() return session_dir end

function M.ensure_real_buffer()
  local current = vim.api.nvim_get_current_buf()

  -- if current buffer is valid and listed → ok
  if vim.api.nvim_buf_is_valid(current) and vim.bo[current].buflisted then return end

  -- otherwise force a real buffer
  vim.cmd "enew"
  vim.bo.buflisted = true
end

local resession = require "resession"

function M.save_session(group_name)
  if not group_name then
    vim.notify("No group name provided", vim.log.levels.ERROR)
    return
  end

  local session = M.session_name(group_name)

  local ok, err = pcall(function() resession.save(session, { dir = "project", notify = true }) end)

  if not ok then
    vim.notify("SAVE FAILED: " .. err, vim.log.levels.ERROR)
    return
  end

  -- vim.notify("SAVE OK: " .. session)
  if debug == true then
    vim.schedule(function()
      vim.notify "Sessions list:"
      local sessions = require("resession").list { dir = "project" }

      vim.notify("Sessions: " .. vim.inspect(sessions))
    end)
  end
end

-- core/buffer_groups/groups.lua

-- existing code...

function M.get_buffers(group_name)
  local session_file = M.session_name(group_name) .. ".json"
  local session_path = vim.fn.stdpath "data" .. "/project/" .. session_file

  if vim.fn.filereadable(session_path) == 0 then
    vim.notify("Session file not found: " .. session_path, vim.log.levels.WARN)
    return {}
  end

  local ok, data = pcall(function()
    local content = table.concat(vim.fn.readfile(session_path), "\n")
    return vim.json.decode(content)
  end)

  if not ok or not data then
    vim.notify("Failed to read session: " .. tostring(data), vim.log.levels.ERROR)
    return {}
  end

  local bufs = {}
  for _, buf in ipairs(data.buffers or {}) do
    if buf.name and buf.name ~= "" then table.insert(bufs, vim.fn.fnamemodify(buf.name, ":t")) end
  end

  return bufs
end

return M
