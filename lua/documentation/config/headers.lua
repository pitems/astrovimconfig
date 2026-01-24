local M = {}

M.sections = {
  functions = {
    key = "functions",
    title = "Functions",
    icon = "➕",
    renderer = "render_functions", -- name only, no function ref
  },
  variables = {
    key = "variables",
    title = "Variables",
    icon = "📦",
    renderer = "render_variables",
  },
}

return M

