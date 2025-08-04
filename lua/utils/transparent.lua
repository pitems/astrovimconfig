local M = {}
local is_enabled = false

function M.apply_transparency()
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

function M.remove_transparency()
  vim.api.nvim_set_hl(0, "Normal", { bg = "#1e1e2e" }) -- default dark bg
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e1e2e" })
end

function M.toggle()
  is_enabled = not is_enabled
  if is_enabled then
    M.apply_transparency()
  else
    M.remove_transparency()
  end
end

function M.setup(opts)
  is_enabled = opts.enabled or false
  if is_enabled then
    M.apply_transparency()
  else
    M.remove_transparency()
  end

  vim.api.nvim_create_user_command("ToggleTransparency", function()
    M.toggle()
  end, {})
end

return M
