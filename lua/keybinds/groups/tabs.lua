return {
  ["<leader>T"] = {
    name = "Tab Tools",
    n = { "<cmd>tabnew<CR>", "New Tab" },
    c = { "<cmd>tabclose<CR>", "Close Tab" },
    o = { "<cmd>tabonly<CR>", "Close Other Tabs" },
    l = { "<cmd>Telescope scope buffers<CR>", "List Tabs" },
    r = {
      function()
        local newname = vim.fn.input "Rename Tab: "
        vim.t[vim.api.nvim_get_current_tabpage()].tab_name = newname
      end,
      "Rename Tab (requires bufferline)",
    },
    m = {
      function()
        local tab = tonumber(vim.fn.input "Move buffer to tab #: ")
        if tab then vim.cmd("ScopeMoveBuf " .. tab) end
      end,
      "Move Buffer to Tab",
    },
  },
}

