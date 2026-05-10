local M = {}

M.filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }

vim.api.nvim_set_hl(0, "@lsp.type.component", { link = "@type" })

function M.vue_language_server_path()
  return vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
end

function M.vue_plugin()
  return {
    name = "@vue/typescript-plugin",
    location = M.vue_language_server_path(),
    languages = { "vue" },
    configNamespace = "typescript",
    enableForWorkspaceTypeScriptVersions = true,
  }
end

function M.ts_ls(opts)
  opts = opts or {}
  opts.filetypes = M.filetypes
  opts.init_options = vim.tbl_deep_extend("force", opts.init_options or {}, {
    plugins = { M.vue_plugin() },
  })
  return opts
end

function M.vue_ls(opts)
  opts = opts or {}
  opts.filetypes = { "vue" }
  return opts
end

return M
