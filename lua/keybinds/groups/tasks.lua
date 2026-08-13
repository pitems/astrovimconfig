return {
  ["<leader>t"] = {
    name = "Tasks & Notes",
    t = { "<cmd>Dooing<CR>", "Open Global Todos" },
    T = { "<cmd>DooingLocal<CR>", "Open Project Todos" },
    n = { "<cmd>DooingDue<CR>", "Show Due Todos" },
    b = { "<cmd>Bloocky<CR>", "Open Timeblocking Calendar" },
    B = { "<cmd>BloockySidebar<CR>", "Open Calendar Sidebar" },
    e = { name = "Testing" },
    z = { name = "Notes" },
  },
}
