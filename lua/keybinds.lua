local wk = require "which-key"

local modules = {
  "keybinds.groups.general",
  "keybinds.groups.documentation",
  "keybinds.groups.flutter",
  "keybinds.groups.language",
  "keybinds.groups.marks",
  "keybinds.groups.debugger",
  "keybinds.groups.tabs",
  "keybinds.groups.search",
  "keybinds.groups.live_server",
}

local mappings = {}
for _, module in ipairs(modules) do
  mappings = vim.tbl_extend("force", mappings, require(module))
end

wk.register(mappings)

