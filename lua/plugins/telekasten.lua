return {
  "renerocksai/telekasten.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = { "Telekasten" },
  keys = {
    { "<leader>zn", "<cmd>Telekasten new_note<CR>", desc = "New Note" },
    { "<leader>zz", "<cmd>Telekasten panel<CR>", desc = "Telekasten Panel" },
    { "<leader>zf", "<cmd>Telekasten find_notes<CR>", desc = "Find Notes" },
    { "<leader>zg", "<cmd>Telekasten search_notes<CR>", desc = "Search Notes (Grep)" },
    { "<leader>zd", "<cmd>Telekasten goto_today<CR>", desc = "Today’s Note" },
    { "<leader>zc", "<cmd>Telekasten show_calendar<CR>", desc = "Calendar" },
    { "<leader>zb", "<cmd>Telekasten show_backlinks<CR>", desc = "Backlinks" },
    { "<leader>zt", "<cmd>Telekasten toggle_todo<CR>", desc = "Toggle TODO" },
  },
  opts = function()
    local home = vim.fn.expand("~") .. "/notes"
    return {
      home = home,
      dailies = home .. "/daily",
      weeklies = home .. "/weekly",
      templates = home .. "/templates",
      extension = ".md",
      follow_creates_nonexisting = true,
      auto_set_filetype = false,
      template_new_note = home .. "/templates/new_note.md",
      template_new_daily = home .. "/templates/daily.md",
      template_new_weekly = home .. "/templates/weekly.md",
    }
  end,
}
