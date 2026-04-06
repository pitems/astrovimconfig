-- core/buffer_groups/init.lua

local M = {}

M.state = require "core.buffer_groups.state"
M.groups = require "core.buffer_groups.groups"
M.switch = require "core.buffer_groups.switch"
M.ui = require "core.buffer_groups.ui"
M.utils = require "core.buffer_groups.utils"

function M.setup() M.utils.setup_keymaps() end

return M
