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
      local flutter_tools = require "flutter-tools"
      local flutter_config = require "flutter-tools.config"

      -- Disable flutter-tools' legacy renderer before it registers its
      -- autocmds. Neovim 0.12 handles document colors natively below.
      flutter_config.lsp.color.enabled = false

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("flutter_document_colors", { clear = true }),
        pattern = "*.dart",
        callback = function(args)
          if vim.lsp.document_color then vim.lsp.document_color.enable(true, { bufnr = args.buf }) end
        end,
      })

      flutter_tools.setup {
        fvm = true,

        ui = {
          border = "rounded",
          notification_style = "native", -- recommended value in new version
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
            local dap = require "dap"

            dap.set_log_level "TRACE"

            dap.defaults.flutter.exception_breakpoints = {
              { filter = "uncaught", action = "ignore" },
            }

            require("dap.ext.vscode").load_launchjs()
          end,
        },

        flutter_run = {
          use_launchjson = true,
          prompt_project_type = true,
        },

        lsp = {
          on_attach = function(client, bufnr) vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr }) end,

          -- ❗ DO NOT override capabilities manually
          -- The internal merge in new flutter-tools is correct.

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
