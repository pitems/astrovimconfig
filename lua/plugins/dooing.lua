-- For lazy.nvim
return {
  "atiladefreitas/dooing",
  config = function()
    require("dooing").setup({
      keymaps = {
        toggle_window = "<leader>td",
        open_project_todo = "<leader>tD",
        show_due_notification = "<leader>tN",
      },
    })
  end,
}


