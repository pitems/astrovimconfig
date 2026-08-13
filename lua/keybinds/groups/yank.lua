local paths = require "user.path_utils"

return {
  ["<leader>y"] = {
    name = "Yank / Copy",
    o = { "y", "Use normal yank operator" },
    p = { paths.relative_path, "Copy relative path" },
    P = { paths.absolute_path, "Copy absolute path" },
    f = { paths.filename, "Copy filename" },
    d = { paths.directory, "Copy containing directory" },
  },
}
