---@type LazySpec
return {
  "mattn/emmet-vim",
  init = function()
    vim.g.user_emmet_expandabbr_key = "<C-y>"
  end,
  ft = {
    "html",
    "css",
    "scss",
    "sass",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "xml",
  },
}
