---@type LazySpec
return {
  "L3MON4D3/LuaSnip",
  version = "1.*",
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local luasnip = require("luasnip")

    -- Load all snippets from friendly-snippets except for Dart
    require("luasnip.loaders.from_vscode").lazy_load({
      -- exclude = { "dart" }, -- Exclude Dart snippets to avoid duplication
    })

     luasnip.filetype_extend("dart", { "flutter" })

    -- Optional: Debug loaded snippets to confirm Dart is excluded
    print(vim.inspect(luasnip.snippets))
  end,
}
