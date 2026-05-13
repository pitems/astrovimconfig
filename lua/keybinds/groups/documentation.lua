local documentator = require "documentation.documentation_creator"
local cli_bridge = require "documentation.cli_bridge"

return {
  ["<leader>D"] = {
    name = "Documentation",
    d = { function() documentator.open_or_create_doc() end, "Open/Create documentation for file" },
    n = { function() cli_bridge.insert_context_block("notes") end, "Insert Notes block" },
    w = { function() cli_bridge.insert_context_block("warning") end, "Insert Warning block" },
    e = { function() cli_bridge.insert_context_block("examples") end, "Insert Examples block" },
    c = { function() cli_bridge.insert_context_block("class") end, "Insert Class block" },
    f = { function() cli_bridge.insert_context_block("function") end, "Insert Function block" },
    v = { function() cli_bridge.insert_context_block("variable") end, "Insert Variable block" },
    a = {
      function()
        local ft = vim.bo.filetype
        if ft ~= "markdown" then
          vim.notify("Not a markdown file!", vim.log.levels.WARN)
          return
        end

        local picker = require "documentation.ui.dependency_picker"
        local finder = require "documentation.finders.dependency_finder"
        local md_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local dependencies = finder.list_dependencies_from_md(md_lines)
        picker.show_dependencies(dependencies)
      end,
      "Open Dependencies for current doc",
    },
  },
}
