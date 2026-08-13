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
  "keybinds.groups.yank",
  "keybinds.groups.rapid_api",
}

local mappings = {}
for _, module in ipairs(modules) do
  mappings[#mappings + 1] = require(module)
end

local specs = {}

local function add_spec(lhs, rhs, desc)
  local spec = { lhs }
  if rhs ~= nil then spec[#spec + 1] = rhs end
  if desc then spec.desc = desc end
  specs[#specs + 1] = spec
end

local function convert_group(prefix, group)
  if group.name then specs[#specs + 1] = { prefix, group = group.name } end

  for key, value in pairs(group) do
    if key ~= "name" then
      local lhs = prefix .. key
      if type(value) == "string" then
        -- Legacy which-key strings are descriptions without a command.
        add_spec(lhs, nil, value)
      elseif type(value) == "table" then
        local first, second = value[1], value[2]
        if (type(first) == "function" or type(first) == "string") and type(second) == "string" then
          add_spec(lhs, first, second)
        else
          convert_group(lhs, value)
        end
      end
    end
  end
end

for _, module in ipairs(mappings) do
  for lhs, value in pairs(module) do
    if type(value) == "table" then
      local first, second = value[1], value[2]
      if (type(first) == "function" or type(first) == "string") and type(second) == "string" then
        add_spec(lhs, first, second)
      else
        convert_group(lhs, value)
      end
    elseif type(value) == "string" then
      add_spec(lhs, nil, value)
    end
  end
end

wk.add(specs)
