return {
  ["<leader>d"] = {
    name = "Debugger",
    k = { function() require("dap.repl").clear() end, "Klear Konsole" },
  },
}

