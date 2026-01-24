local M = {}

M.sections = {

  {
    key = "variables",
    title = "Variables",
    icon = "📦",
    renderer = "render_variables",
  },
  {
    key = "functions",
    title = "Functions",
    icon = "➕",
    renderer = "render_functions",
  },
}

return M

