return 
{
  "akinsho/toggleterm.nvim",
  branch = "main",
  config = function()
    require("toggleterm").setup({
      size = 20, -- You can adjust this as per your requirement
      open_mapping = [[<C-\>]],  -- The key to toggle the terminal
      direction = "float",  -- Ensure terminal opens in a floating window
    })
  end,
}
