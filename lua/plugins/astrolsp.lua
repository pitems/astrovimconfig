-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = true,
        allow_filetypes = {},
        ignore_filetypes = {},
      },
      disabled = {},
      timeout_ms = 1000,
    },
    commands = {
      Format = {
        function() vim.lsp.buf.format() end,
        cond = "textDocument/formatting",
        desc = "Format file with LSP",
      },
    },
    servers = {},
    config = {},
    handlers = {},
    autocmds = {
      lsp_codelens_refresh = {
        cond = "textDocument/codeLens",
        {
          event = { "InsertLeave", "BufEnter" },
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then
              vim.lsp.codelens.refresh { bufnr = args.buf }
            end
          end,
        },
      },
    },
    mappings = {
      n = {
        ["gD"] = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["gd"] = {
          function() vim.lsp.buf.definition() end,
          desc = "Show the definition of current symbol",
          cond = "textDocument/definition",
        },
        ["gI"] = {
          function() vim.lsp.buf.implementation() end,
          desc = "Implementation of current symbol",
          cond = "textDocument/implementation",
        },
        ["gy"] = {
          function() vim.lsp.buf.type_definition() end,
          desc = "Definition of current type",
          cond = "textDocument/typeDefinition",
        },
        ["<Leader>la"] = {
          function() vim.lsp.buf.code_action() end,
          desc = "Code Action",
          cond = "textDocument/codeAction",
        },
        ["<Leader>lA"] = {
          function() vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } } end,
          desc = "LSP source action",
          cond = "textDocument/codeAction",
        },
        ["<Leader>lf"] = {
          function() vim.lsp.buf.format { async = true } end,
          desc = "Format Document",
          cond = "textDocument/formatting",
        },
        ["<Leader>lr"] = {
          function() vim.lsp.buf.rename() end,
          desc = "Rename current symbol",
          cond = "textDocument/rename",
        },
        ["<Leader>lh"] = {
          function() vim.lsp.buf.signature_help() end,
          desc = "Signature help",
          cond = "textDocument/signatureHelp",
        },
        ["<Leader>lR"] = {
          function() vim.lsp.buf.references() end,
          desc = "Search references",
          cond = "textDocument/references",
        },
        ["<Leader>uh"] = {
          function() require("astrolsp.toggles").buffer_inlay_hints() end,
          desc = "Toggle LSP inlay hints (buffer)",
          cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
        },
        ["<Leader>uH"] = {
          function() require("astrolsp.toggles").inlay_hints() end,
          desc = "Toggle LSP inlay hints (global)",
          cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
        },
      },
      v = {
        ["<Leader>la"] = {
          function() vim.lsp.buf.code_action() end,
          desc = "Code Action",
          cond = "textDocument/codeAction",
        },
        ["<Leader>lf"] = {
          function() vim.lsp.buf.format { async = true } end,
          desc = "Format Document",
          cond = "textDocument/rangeFormatting",
        },
      },
    },
    on_attach = function(client, bufnr)
      -- Custom on_attach function
    end,
  },
}
