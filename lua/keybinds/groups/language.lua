return {
  ["<leader>l"] = {
    name = "Language Tools",
    f = { function() vim.lsp.buf.format { async = true } end, "Format Document" },
    r = { function() vim.lsp.buf.rename() end, "Rename Symbol" },
  },
}

