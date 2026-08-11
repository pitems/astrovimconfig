local wk = require "which-key"

local modules = {
  "keybinds.groups.general",
  "keybinds.groups.buffers",
  "keybinds.groups.documentation",
  "keybinds.groups.json",
  "keybinds.groups.flutter",
  "keybinds.groups.insert",
  "keybinds.groups.language",
  "keybinds.groups.marks",
  "keybinds.groups.debugger",
  "keybinds.groups.tabs",
  "keybinds.groups.search",
  "keybinds.groups.live_server",
  "keybinds.groups.telekasten",
  "keybinds.groups.tasks",
  "keybinds.groups.rapid_api",
}

local mappings = {}
for _, module in ipairs(modules) do
  mappings = vim.tbl_extend("force", mappings, require(module))
end

wk.register(mappings)
