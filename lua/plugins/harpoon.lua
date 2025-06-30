return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    local wk = require("which-key")

    -- Setup harpoon
    harpoon.setup()

    -- Register keybinds with which-key
    wk.register({
      H = {
        name = "Harpoon",
        a = { function() require("harpoon.mark").add_file() end, "Add File to Harpoon" },
        d = { function() require("harpoon.mark").rm_file() end, "Remove File from Harpoon" },
        c = { function() require("harpoon.ui").clear() end, "Clear all items on Harpoon" },
        m = { function() require("harpoon.ui").toggle_quick_menu() end, "Toggle Quick Menu" },
        p = { function() require("harpoon.ui").nav_prev() end, "Navigate to Previous File" },
        n = { function() require("harpoon.ui").nav_next() end, "Navigate to Next File" },
      }
    }, { prefix = "<leader>" })
  end,
}
