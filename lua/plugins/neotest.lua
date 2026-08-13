return {
  "nvim-neotest/neotest",
  event = "VeryLazy",
  keys = {
    { "<leader>tex", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
    { "<leader>teF", function() require("neotest").run.run(vim.fn.expand "%") end, desc = "Run Tests in File" },
    { "<leader>tea", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Run All Tests" },
    { "<leader>tes", function() require("neotest").summary.toggle() end, desc = "Toggle Test Summary" },
    { "<leader>teo", function() require("neotest").output.open { enter = true } end, desc = "Show Test Output" },
    { "<leader>teX", function() require("neotest").run.run { strategy = "dap" } end, desc = "Debug Nearest Test" },
  },
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "sidlatau/neotest-dart",
  },
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}

    table.insert(opts.adapters, require("neotest-dart") {
      command = vim.fn.executable("fvm") == 1 and "fvm flutter" or "flutter",
      use_lsp = true,
    })

    opts.output = opts.output or {}
    opts.output.open_on_run = true

    return opts
  end,
  config = function(_, opts)
    require("neotest").setup(opts)
  end,
}
