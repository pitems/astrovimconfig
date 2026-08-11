-- ~/.config/nvim/lua/user/theme.lua

local M = {}

M.colorscheme = "luna"

-- Reset (mandatory)
vim.cmd "highlight clear"
if vim.fn.exists "syntax_on" == 1 then vim.cmd "syntax reset" end

-- Background preferences PER THEME
local light_themes = {
  ["catppuccin-latte"] = true,
  ["zenwritten"] = true,
  ["forestbones"] = true,
}

local dark_themes = {
  ["cyberdream"] = true,
  ["zenbones"] = true,
  ["neobones"] = true,
  ["rosebones"] = true,
  ["nordbones"] = true,
  ["tokyobones"] = true,
  ["kanagawabones"] = true,
  ["luna"] = true,
}

if light_themes[M.colorscheme] then
  vim.o.background = "light"
elseif dark_themes[M.colorscheme] then
  vim.o.background = "dark"
else
  vim.o.background = "dark"
end

return M
