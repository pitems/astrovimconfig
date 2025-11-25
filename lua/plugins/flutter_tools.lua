---@type LazySpec
return {
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("flutter-tools").setup {
        fvm = true,
        ui = {
          border = "rounded",
          notification_style = "plugin",
          device_picker = "native", -- fix for picker closing
        },
        decorations = {
          statusline = { app_version = true, device = true },
        },
        outline = { open_cmd = "30vnew", auto_open = false },
        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
          register_configurations = function(_)
            local dap = require("dap")
            local dapui = require("dapui")

            dap.set_log_level("TRACE")
            dap.defaults.flutter.exception_breakpoints = {
              { filter = "uncaught", action = "ignore" },
            }

            dapui.setup({
              icons = { expanded = "▾", collapsed = "▸" },
              mappings = {
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
              },
              layouts = {
                {
                  elements = {
                    { id = "scopes", size = 0.25 },
                    { id = "breakpoints", size = 0.25 },
                    { id = "stacks", size = 0.25 },
                    { id = "watches", size = 0.25 },
                  },
                  size = 40,
                  position = "left",
                },
                {
                  elements = {
                    { id = "repl", size = 1.0 },
                    { id = "console", size = 0.0 },
                  },
                  size = 20,
                  position = "bottom",
                },
              },
              floating = {
                border = "single",
                mappings = { close = { "q", "<Esc>" } },
              },
              windows = { indent = 1 },
            })

            dap.listeners.after.event_initialized["dapui_config"] = function()
              dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
              dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
              dapui.close()
            end

            require("dap.ext.vscode").load_launchjs()
          end,
        },
         debug = true, -- this is the main flag
        dev_log = { enabled = false, notify_errors = true},
  --       dev_log = {
  --   enabled = true,
  --   open_cmd = "tabedit", -- optional: open logs in a tab
  -- },
         -- optional: force prompt every time
        flutter_run = {
             use_launchjson = true,
    always_show_picker = true,
          prompt_project_type = true
        },
        lsp = {
          on_attach = function(client, bufnr)
            vim.api.nvim_buf_set_keymap(bufnr, "n", "gd",
              "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
          end,
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          color = { enabled = true, virtual_text = true, virtual_text_str = "■" },
          settings = {
            lineLength = 120,
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            enableSdkFormatter = true,
            updateImportsOnRename = true,
          },
        },
      }
    end,
  },
  {
    "wa11breaker/flutter-bloc.nvim",
    ft = { "dart" },
  },
}
