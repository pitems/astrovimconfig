return {
  "renerocksai/telekasten.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = { "Telekasten" },
  keys = {
    { "<leader>tzn", "<cmd>Telekasten new_note<CR>", desc = "New Note" },
    { "<leader>tzz", "<cmd>Telekasten panel<CR>", desc = "Telekasten Panel" },
    { "<leader>tzf", "<cmd>Telekasten find_notes<CR>", desc = "Find Notes" },
    { "<leader>tzg", "<cmd>Telekasten search_notes<CR>", desc = "Search Notes (Grep)" },
    { "<leader>tzd", "<cmd>Telekasten goto_today<CR>", desc = "Today’s Note" },
    { "<leader>tzc", "<cmd>Telekasten show_calendar<CR>", desc = "Calendar" },
    { "<leader>tzb", "<cmd>Telekasten show_backlinks<CR>", desc = "Backlinks" },
    { "<leader>tzt", "<cmd>Telekasten toggle_todo<CR>", desc = "Toggle TODO" },
 -- use function mappings so lazy.nvim loads telekasten first
    -- 🔄 Switch vaults
    { "<leader>vs", "<cmd>Telekasten switch_vault<CR>", desc = "Switch Vault (picker)" },
    { "<leader>vF", function() require("telekasten").switch_vault("flutter") end, desc = "Switch to Flutter vault" },
    { "<leader>vR", function() require("telekasten").switch_vault("rust") end, desc = "Switch to Rust vault" },
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
      vaults = {
        flutter = {
          home = home .. "/programming/flutter",
        },
        rust = {
          home = home .. "~/programming/rust",
        },
      },
    }
  end,
}
