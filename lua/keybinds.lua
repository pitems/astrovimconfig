local wk = require("which-key")
local tabsession = require("user.tabsession")

wk.register({
  ["<leader>D"] = { function() vim.cmd("Dooing") end, "Dooing" },
  ["<leader>z"] = { function() vim.cmd("ZenMode") end, "ZenMode" },

  ["<leader>F"] = {
    name = "Flutter",
    R = { "<cmd>FlutterRestart<CR>", "Hot Restart App" },
    s = { "<cmd>FlutterRun<CR>", "Run App" },
    c = { "<cmd>Telescope flutter commands<CR>", "Open Flutter Commands" },
    d = { "<cmd>FlutterDevices<CR>", "Flutter Devices" },
    e = { "<cmd>FlutterEmulators<CR>", "Flutter Emulators" },
    q = { "<cmd>FlutterQuit<CR>", "Quit Running Application" },
    r = { "<cmd>FlutterReload<CR>", "Hot Reload App" },
    v = { "<cmd>Telescope flutter fvm<CR>", "Flutter Version" },
    y = { "<cmd>FlutterCopyProfilerUrl<CR>", "Flutter Dev Tools Link" },
  },

  ["<leader>l"] = {
    name = "Language Tools",
    f = { function() vim.lsp.buf.format { async = true } end, "Format Document" },
    r = { function() vim.lsp.buf.rename() end, "Rename Symbol" },
  },

  ["<leader>k"] = {
    name = "Marks",
    [""] = { "<cmd>delmarks!<CR>", "Clear All Marks" },
  },

  ["<leader>d"] = {
    name = "Debugger",
    k = { function() require("dap.repl").clear() end, "Klear Konsole" },
  },

  ["<leader>T"] = {
    name = "Tab Sessions",
    t = { tabsession.load_tab, "Open Tab Session" },
    n = { tabsession.save_current_tab, "Name & Save Tab Session" },
    d = { tabsession.delete_current_tab, "Delete Tab Session" },
  },
})

