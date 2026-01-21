local M = {}

M.themes = {
  "cyberdream",
  "catppuccin",
  "catppuccin-latte",
  "tokyonight",
  "kanagawa",
  "rose-pine",
  "gruvbox",
  "terafox",
  -- zenbones family
  "zenbones",
  "neobones",
  "forestbones",
  "rosebones",
  "nordbones",
  "tokyobones",
  "kanagawabones",
  "zenwritten",
}

local theme_file = vim.fn.stdpath("config") .. "/lua/user/theme.lua"

function M.apply(theme)
  -- reset
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  -- background logic
  local light = {
    ["catppuccin-latte"] = true,
    ["zenwritten"] = true,
    ["forestbones"] = true,
  }
  vim.o.background = light[theme] and "light" or "dark"

  -- apply theme
  vim.cmd.colorscheme(theme)

  -- persist
  local content = ([[local M = {}
M.colorscheme = "%s"
return M
]]):format(theme)

  vim.fn.writefile(vim.split(content, "\n"), theme_file)
end

function M.pick()
  require("telescope.pickers").new({}, {
    prompt_title = "Themes",
    finder = require("telescope.finders").new_table(M.themes),
    sorter = require("telescope.config").values.generic_sorter({}),
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selection = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        M.apply(selection[1])
      end)
      return true
    end,
  }):find()
end

return M
