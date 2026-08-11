-- lua/user/autocmds.lua
local autocmds = {
  {
    event = { "VimEnter", "ColorScheme" },
    desc = "Style LSP inlay hints",
    callback = function()
      vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#808080", italic = true })
      vim.api.nvim_set_hl(0, "@lsp.type.inlayHint", { link = "LspInlayHint" })
    end,
  },
  {
    event = "ColorScheme",
    desc = "Markdown highlights",
    callback = function()
      require("user.markdown").apply()
    end,
  },
  {
    event = "FileType",
    desc = "Editor width hints for code buffers",
    callback = function(args)
      require("user.format_widths").apply(vim.bo[args.buf].filetype)
    end,
  },
  {
    event = "FileType",
    desc = "Disable LSP inlay hints for Dart/Flutter",
    callback = function(args)
      if vim.lsp.inlay_hint then
        vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
      end
    end,
    pattern = "dart",
  },
  {
    event = { "BufEnter", "TextChanged", "TextChangedI", "InsertLeave", "BufWritePost" },
    desc = "HTML diagnostics via htmlhint",
    callback = function(args)
      if vim.bo[args.buf].filetype ~= "html" then
        return
      end

      require("user.html_diagnostics").schedule(args.buf)
    end,
  },
  {
    event = "BufWritePost",
    desc = "Refresh generated documentation from source saves",
    callback = function(args)
      require("documentation.documentation_creator").sync_from_source_buffer(args.buf)
    end,
  },
}

if vim.fn.has "mac" == 1 then
  table.insert(autocmds, {
    event = "BufReadCmd",
    pattern = { "*.pdf", "*.PDF" },
    desc = "Open PDFs in macOS Preview",
    callback = function(args)
      local file = vim.api.nvim_buf_get_name(args.buf)
      if file == "" then
        return
      end

      vim.fn.jobstart({ "open", "-a", "Preview", file }, { detach = true })

      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          vim.api.nvim_buf_delete(args.buf, { force = true })
        end
      end)
    end,
  })
end

return autocmds
