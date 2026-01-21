return {
  "echasnovski/mini.surround",
  version = false,
  config = function()
    require("mini.surround").setup({
      mappings = {
        add = "gza",            -- Add surrounding
        delete = "gzd",         -- Delete surrounding
        replace = "gzr",        -- Replace surrounding
        find = "gzn",           -- Find next surrounding
        find_left = "gzp",      -- Find previous surrounding
        highlight = "gzh",      -- Highlight surrounding
        update_n_lines = "gzl", -- Update number of lines

        -- Visual mode mapping to add surrounding
        -- Leader-style: press `gz` in VISUAL mode
        add_visual = "gz",

        -- Disable default conflict mappings
        suffix_last = "",
        suffix_next = "",
      },
    })
  end,
}
