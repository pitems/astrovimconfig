-- lua/user/autocmds.lua
return {
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
    event = { "BufEnter", "TextChanged", "TextChangedI", "InsertLeave", "BufWritePost" },
    desc = "HTML diagnostics via htmlhint",
    callback = function(args)
      if vim.bo[args.buf].filetype ~= "html" then
        return
      end

      require("user.html_diagnostics").schedule(args.buf)
    end,
  },
}
