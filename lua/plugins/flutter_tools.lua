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
      local flutter_tools = require("flutter-tools")

      flutter_tools.setup({
        fvm = true,

        ui = {
          border = "rounded",
          notification_style = "native",  -- recommended value in new version
        },

        decorations = {
          statusline = {
            app_version = true,
            device = true,
            project_config = false,
          },
        },

        outline = {
          open_cmd = "30vnew",
          auto_open = false,
        },

        dev_log = {
          enabled = false,
          notify_errors = true,
        },

        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
          register_configurations = function(paths)
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
                  },
                  size = 20,
                  position = "bottom",
                },
              },
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

        flutter_run = {
          use_launchjson = true,
          prompt_project_type = true,
        },

        lsp = {
          on_attach = function(client, bufnr)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
          end,

          -- ❗ DO NOT override capabilities manually
          -- The internal merge in new flutter-tools is correct.

          color = {
            enabled = true,
            virtual_text = true,
            virtual_text_str = "■",
          },

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
      })
    end,
  },

  {
    "wa11breaker/flutter-bloc.nvim",
    ft = { "dart" },
  },
}
