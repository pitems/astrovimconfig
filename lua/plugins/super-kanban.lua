---@type LazySpec
return {
  "hasansujon786/super-kanban.nvim",
  cmd = "SuperKanban",
  dependencies = {
    "folke/snacks.nvim",
  },
  opts = {
    markdown = {
      notes_dir = "./.kanban/notes/",
      list_heading = "h2",
      default_template = {
        "## Backlog\n",
        "## Todo\n",
        "## Work in progress\n",
        "## Completed\n",
      },
    },
  },
  config = function(_, opts)
    -- super-kanban creates only the final notes directory itself. Create the
    -- nested project directory first so opening a card note can write it.
    vim.fn.mkdir(vim.fs.joinpath(vim.fn.getcwd(), ".kanban", "notes"), "p")

    require("super-kanban").setup(opts)

    -- super-kanban can lose a card's visual index after scrolling or when
    -- moving between columns with different card counts. Its horizontal
    -- navigation currently compares that nil value with a number.
    local Card = require("super-kanban.ui.card")
    if not Card._nil_visual_index_patch then
      local jump_horizontal = Card.jump_horizontal

      Card.jump_horizontal = function(self, direction)
        local visual_index = self.visible_index or self.index
        local original_visible_index = self.visible_index
        self.visible_index = visual_index

        local ok, err = pcall(jump_horizontal, self, direction)

        self.visible_index = original_visible_index
        if not ok then
          error(err)
        end
      end

      Card._nil_visual_index_patch = true
    end
  end,
  keys = {
    {
      "<leader>kk",
      function()
        local board = vim.fs.joinpath(vim.fn.getcwd(), "kanban.md")

        if vim.fn.filereadable(board) == 0 then
          require("super-kanban").create(board)
        else
          require("super-kanban").open(board)
        end
      end,
      desc = "Open project Kanban",
    },
    {
      "<leader>kK",
      "<cmd>SuperKanban open<cr>",
      desc = "Pick Kanban board",
    },
  },
}
