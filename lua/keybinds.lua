local wk = require("which-key")
local tabsession = require("user.tabsession")
local documentator = require("documentation.documentation_creator")
-- local colorscheme = require("user.colorscheme")
wk.register({
  -- ["<leader>D"] = { function() vim.cmd("Dooing") end, "Dooing" },
  ["<leader>Z"] = { function() vim.cmd("ZenMode") end, "ZenMode" },

  ["<leader>D"] = { function() documentator.open_or_create_doc() end, "Open/Create documentation for file" },
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

    o = { "<cmd>FlutterOutlineToggle<CR>", "Flutter Outline Toggle" },
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
    name = "Tab Tools",
    n = { "<cmd>tabnew<CR>", "New Tab" },
    c = { "<cmd>tabclose<CR>", "Close Tab" },
    o = { "<cmd>tabonly<CR>", "Close Other Tabs" },
    l = { "<cmd>Telescope scope buffers<CR>", "List Tabs" },
    r = { function()
      local newname = vim.fn.input("Rename Tab: ")
      vim.t[vim.api.nvim_get_current_tabpage()].tab_name = newname
    end, "Rename Tab (requires bufferline)" },
    m = {
      function()
        local tab = tonumber(vim.fn.input("Move buffer to tab #: "))
        if tab then vim.cmd("ScopeMoveBuf " .. tab) end
      end,
      "Move Buffer to Tab",
},
  },

  ["<leader>s"] = {
    name = "Spectre",
    p = {
      function()
        require("spectre").open()
      end,
      "Search Project (Spectre)",
    },
    w = {
      function()
        require("spectre").open_visual({ select_word = true })
      end,
      "Search Current Word (Project)",
    },
    f = {
        name = "File Search",
        f = {
          function()
            require("spectre").open_file_search()
          end,
          "Search in Current File",
        },
        w = {
          function()
            require("spectre").open_file_search({ select_word = true })
          end,
          "Search Word in File",
        },
      },
  },

  ["<tab>"] = { "<cmd>tabnext<CR>", "Next Tab" },
  ["<s-tab>"] = { "<cmd>tabprevious<CR>", "Previous Tab" },
  -- ["<leader>u"] = {
  --   name = "UI / Utilities", -- Add a name to the 'u' group
  --   T = { function() require("user.colorscheme").pick() end, "Pick Colorscheme" },
  -- }
})

