local surround = require "documentation.surround_actions"

return {
  ["<leader>i"] = {
    name = "Insert",
    s = {
      name = "Surround",
      a = { surround.add, "Add Surround" },
      d = { surround.delete, "Delete Surround" },
      r = { surround.replace, "Replace Surround" },
      h = { surround.highlight, "Highlight Surround" },
      n = { surround.find_next, "Find Next Surround" },
      p = { surround.find_prev, "Find Prev Surround" },
      l = { surround.update_lines, "Update Surround Lines" },
    },
  },
}
