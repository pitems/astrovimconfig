local M = {}

local session_dir = "project"

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

  vim.schedule(function()
    vim.notify "Sessions list:"
    local sessions = require("resession").list { dir = "project" }

    vim.notify("Sessions: " .. vim.inspect(sessions))
  end)
end

return M
