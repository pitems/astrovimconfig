return {
  ["<leader>Z"] = { function() vim.cmd "ZenMode" end, "ZenMode" },
  ["<tab>"] = { "<cmd>tabnext<CR>", "Next Tab" },
  ["<s-tab>"] = { "<cmd>tabprevious<CR>", "Previous Tab" },
}

