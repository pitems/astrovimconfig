local markdown_format = require "documentation.markdown_format"

return {
  ["<leader>l"] = {
    name = "Language Tools",
    f = { function() vim.lsp.buf.format { async = true } end, "Format Document" },
    p = { markdown_format.reflow, "Format Markdown Paragraphs" },
    r = { function() vim.lsp.buf.rename() end, "Rename Symbol" },
  },
}
