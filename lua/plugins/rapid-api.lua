---@type LazySpec
return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
      { "<leader>As", function() require("kulala").run() end, desc = "Send request" },
      { "<leader>Aa", function() require("kulala").run_all() end, desc = "Send all requests" },
      { "<leader>Ar", function() require("kulala").replay() end, desc = "Replay last request" },
    },
    opts = {
      default_env = "default",
      environment_scope = "b",
      response_format = {
        indent = 2,
        expand_tabs = true,
        sort_keys = false,
      },
      ui = {
        display_mode = "split",
        split_direction = "right",
        default_view = "body",
        show_request_summary = true,
        report = {
          show_script_output = true,
          show_asserts_output = true,
          show_summary = true,
        },
      },
      global_keymaps = false,
    },
  },
}
