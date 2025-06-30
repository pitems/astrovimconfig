---@type LazySpec
return {
 {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
"hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("flutter-tools").setup {
        fvm = true, -- uses <workspace>/.fvm/flutter_sdk if enabled
        ui = {
          border = "rounded",
          notification_style = "plugin",
        },
        decorations = {
          statusline = {
            app_version = true,
            device = true,
          },
        },
        outline = {
          open_cmd = "30vnew",
          auto_open = false,
        },
        debugger = {
  enabled = true,
  run_via_dap = true,
  exception_breakpoints = {},
  register_configurations = function(_)
    local dap = require("dap")
    local dapui = require("dapui")

    dap.set_log_level("TRACE")
    dap.defaults.flutter.exception_breakpoints = { { filter = "uncaught", action = "ignore" } }

    -- Setup dap-ui
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
            { id = "scopes",      size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks",      size = 0.25 },
            { id = "watches",     size = 0.25 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl",    size = 1.0 },
            { id = "console", size = 0.0 },
          },
          size = 20,
          position = "bottom",
        },
      },
      floating = {
        max_height = nil,
        max_width = nil,
        border = "single",
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      windows = { indent = 1 },
    })

    -- Automatically open and close dap-ui windows
    -- dap.listeners.after.event_initialized["dapui_config"] = function()
    --   dapui.open()
    -- end
    -- dap.listeners.before.event_terminated["dapui_config"] = function()
    --   dapui.toggle()
    -- end
    -- dap.listeners.before.event_exited["dapui_config"] = function()
    --   dapui.toggle()
    -- end

    -- Load launch.json configurations dynamically
    require("dap.ext.vscode").load_launchjs()
  end,
},
        dev_log = {
          enabled = false,
          notify_errors = false,
        },
lsp = {
          on_attach = function(client, bufnr)
            -- Set up keymaps or other on-attach logic
            local opts = { noremap = true, silent = true }
            vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
          end,
          capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
          -- capabilities = vim.lsp.protocol.make_client_capabilities(),
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
      }
    end,
  },
  {
    "wa11breaker/flutter-bloc.nvim",
    lazy = true, -- Loads only when needed
  },
}
