local wk = require("which-key")
local harpoon = require("harpoon")
local tabsession = require("plugins/tabsession")
wk.add({
  -- Top-level commands
  { "<leader>D", function() vim.cmd("Dooing") end, desc = "Dooing" },
  { "<leader>z", function() vim.cmd("ZenMode") end, desc = "ZenMode" },

  -- Flutter group
  { "<leader>F", group = "Flutter", name = "Flutter" }, -- Group declaration
  { "<leader>FR", "<cmd>FlutterRestart<CR>", desc = "Hot Restart App" },
  { "<leader>Fs", "<cmd>FlutterRun<CR>", desc = "Run App" },
  { "<leader>Fc", "<cmd>Telescope flutter commands<CR>", desc = "Open Flutter Commands" },
  { "<leader>Fd", "<cmd>FlutterDevices<CR>", desc = "Flutter Devices" },
  { "<leader>Fe", "<cmd>FlutterEmulators<CR>", desc = "Flutter Emulators" },
  { "<leader>Fq", "<cmd>FlutterQuit<CR>", desc = "Quit Running Application" },
  { "<leader>Fr", "<cmd>FlutterReload<CR>", desc = "Hot Reload App" },
  { "<leader>Fv", "<cmd>Telescope flutter fvm<CR>", desc = "Flutter Version" },
  { "<leader>Fy", "<cmd>FlutterCopyProfilerUrl<CR>", desc = "Flutter Dev Tools Link" },
}, {
  prefix = "<leader>", -- Set the prefix for all mappings
})


wk.add({
  { "<leader>l", group = "Language Tools" }, -- Create the Language Tools group
  { "<leader>lf", function() vim.lsp.buf.format { async = true } end, desc = "Format Document", cond = "textDocument/formatting" },
  { "<leader>lr", function() vim.lsp.buf.rename() end, desc = "Rename Symbol" }, -- Add Rename Symbol
}, {
  prefix = "<leader>", -- Ensure the prefix is "<leader>"
})


wk.add({
  { "<leader>k", "<cmd>delmarks!<CR>", desc = "Clear All Marks" },
}, { prefix = "<leader>" })

wk.add({
  { "<leader>d", group = "Debugger" }, -- Create the Debugger group
  { "<leader>dk", function() require("dap.repl").clear() end, desc = "Klear Konsole" }, -- Add the keybind
}, {
  prefix = "<leader>", -- Ensure the prefix is "<leader>"
})

-- Set up Harpoon
harpoon:setup()

-- Add Harpoon Keybinds
wk.add({
  { "<leader>H", group = "Harpoon" }, -- Create the Harpoon group
  { "<leader>Ha", function() harpoon:list():add() end, desc = "Add File to Harpoon" },
  { "<leader>Hd", function() harpoon:list():remove() end, desc = "Remove File from Harpoon" },
  { "<leader>Hc", function() harpoon:list():clear() end, desc = "Clear all items on Harpoon" },
  { "<leader>Hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Toggle Quick Menu" },
  { "<leader>Hp", function() harpoon:list():prev() end, desc = "Navigate to Previous File" },
  { "<leader>Hn", function() harpoon:list():next() end, desc = "Navigate to Next File" },
}, {
  prefix = "<leader>", -- Ensure the prefix is "<leader>"
})



-- Add Tab Session Keybinds
wk.add({
  { "<leader>T", group = "Tab Sessions" }, -- Create the Tab Sessions group
  { "<leader>Tt", tabsession.load_tab, desc = "Open Tab Session" },
  { "<leader>Tn", tabsession.save_current_tab, desc = "Name & Save Tab Session" },
  { "<leader>Td", tabsession.delete_current_tab, desc = "Delete Tab Session" },
}, {
  prefix = "<leader>", -- Standard prefix
})
