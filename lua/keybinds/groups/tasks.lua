return {
  ["<leader>t"] = {
    name = "Tasks & Time",
    d = { "<cmd>Dooing<CR>", "Open Global Todos" },
    D = { "<cmd>DooingLocal<CR>", "Open Project Todos" },
    N = { "<cmd>DooingDue<CR>", "Show Due Todos" },
    b = { "<cmd>Bloocky<CR>", "Open Timeblocking Calendar" },
    B = { "<cmd>BloockySidebar<CR>", "Open Calendar Sidebar" },
  },
}
