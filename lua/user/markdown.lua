-- lua/user/highlights/markdown.lua
local M = {}

function M.apply()
  vim.api.nvim_set_hl(0, "@markup.strong", { fg = "#f38ba8", bold = true })
  vim.api.nvim_set_hl(0, "@markup.emphasis", { italic = true })

  vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "#f38ba8", bold = true })
  vim.api.nvim_set_hl(0, "RenderMarkdownWarn", { fg = "#f9e2af" })
  vim.api.nvim_set_hl(0, "RenderMarkdownInfo", { fg = "#89b4fa" })
end

return M
