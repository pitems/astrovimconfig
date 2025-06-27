
return {
  "stevearc/resession.nvim",
  config = function()
    require("resession").setup({
      autosave = {
        enabled = true,
        interval = 300, -- autosave every 5 minutes
        notify = false,
      },
      load_on_setup = false, -- You can make this true if you want to always restore last session
    })
  end,
  lazy = false, -- Make sure it loads early
}
