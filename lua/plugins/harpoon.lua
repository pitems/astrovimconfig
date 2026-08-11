return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    local wk = require("which-key")

    harpoon:setup()

    wk.add({
      { "<leader>H", group = "Harpoon" },
      { "<leader>Ha", function() harpoon:list():add() end, desc = "Add file to Harpoon" },
      { "<leader>Hd", function() harpoon:list():remove() end, desc = "Remove file from Harpoon" },
      { "<leader>Hc", function() harpoon:list():clear() end, desc = "Clear Harpoon list" },
      { "<leader>Hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Toggle Harpoon Menu" },

      -- Navigation like your original
      { "<leader>Hp", function() harpoon:list():prev() end, desc = "Harpoon previous" },
      { "<leader>Hn", function() harpoon:list():next() end, desc = "Harpoon next" },
    })
  end,
}
