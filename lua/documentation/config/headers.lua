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
  {
  key = "dependencies",
  title = "Dependencies",
  icon = "🔗",
  renderer = "render_dependencies",
  },
}

return M

