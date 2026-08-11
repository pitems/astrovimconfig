return {
  "atiladefreitas/bloocky",
  config = function()
    require("bloocky").setup {
      integrations = {
        dooing = {
          enabled = true,
        },
      },
    }
  end,
}
