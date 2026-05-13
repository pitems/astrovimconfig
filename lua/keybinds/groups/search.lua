return {
  ["<leader>s"] = {
    name = "Search / Replace",
    p = {
      function() require("spectre").open() end,
      "Search and Replace in Project",
    },
    w = {
      function() require("spectre").open_visual { select_word = true } end,
      "Search Current Word in Project",
    },
    f = {
      name = "Current File",
      f = {
        function() require("spectre").open_file_search() end,
        "Search and Replace in File",
      },
      w = {
        function() require("spectre").open_file_search { select_word = true } end,
        "Search Current Word in File",
      },
    },
  },
}

