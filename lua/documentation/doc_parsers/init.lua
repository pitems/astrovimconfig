local M = {}

local parsers = {
  dart = require("documentation.doc_parsers.dart"),
  -- lua = require("utils.doc_parsers.lua"), -- later
}

function M.get(filetype)
  return parsers[filetype]
end

return M
