return {
  ["<leader>F"] = {
    name = "Flutter",
    R = { "<cmd>FlutterRestart<CR>", "Hot Restart App" },
    s = { "<cmd>FlutterRun<CR>", "Run App" },
    c = { "<cmd>Telescope flutter commands<CR>", "Open Flutter Commands" },
    d = { "<cmd>FlutterDevices<CR>", "Flutter Devices" },
    e = { "<cmd>FlutterEmulators<CR>", "Flutter Emulators" },
    q = { "<cmd>FlutterQuit<CR>", "Quit Running Application" },
    r = { "<cmd>FlutterReload<CR>", "Hot Reload App" },
    v = { "<cmd>Telescope flutter fvm<CR>", "Flutter Version" },
    y = { "<cmd>FlutterCopyProfilerUrl<CR>", "Flutter Dev Tools Link" },
    o = { "<cmd>FlutterOutlineToggle<CR>", "Flutter Outline Toggle" },
  },
}

