-- lua/user/autocmds.lua
return {
  {
    event = "ColorScheme",
    desc = "Markdown highlights",
    callback = function()
      require("user.markdown").apply()
    end,
  },
}
