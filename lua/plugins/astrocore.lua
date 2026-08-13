local map = vim.keymap.set
local opts = { noremap = true, silent = true }
-- External Configurations
require ("keybinds")
-- Normal mode mappings
map("n", "<leader>ff", ":Telescope find_files<CR>", opts) -- Find files
map("n", "<leader>fg", ":Telescope live_grep<CR>", opts) -- Live grep
map("n", "<leader>fb", ":Telescope buffers<CR>", opts) -- List buffers
map("n", "<leader>fh", ":Telescope help_tags<CR>", opts) -- Find help

-- Insert mode mappings
map("i", "jk", "<Esc>", opts) -- Quickly exit insert mode

-- Visual mode mappings
map("v", "<", "<gv", opts) -- Indent left and stay in visual mode
map("v", ">", ">gv", opts) -- Indent right and stay in visual mode
-- Buffer navigation with S-l and S-h
vim.api.nvim_set_keymap('n', '<S-l>', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-h>', ':bprev<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "<C-a>", "<Cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "LSP Code Action" })
-- In your key mappings section
vim.api.nvim_set_keymap("n", "<C-\\>", "<cmd>ToggleTerm direction=float<cr>", { noremap = true, silent = true })
-- if vim.fn.maparg("<Tab>", "i") ~= "" then
--   vim.api.nvim_del_keymap("i", "<Tab>")
-- end

local wk = require("which-key")

wk.add({
})

return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    opts._map_sections = opts._map_sections or {}
    opts._map_sections.t = { desc = "Tasks & Notes" }

    opts.mappings = opts.mappings or {}
    opts.mappings.n = opts.mappings.n or {}
    opts.mappings.n["<Leader>t"] = opts._map_sections.t

    -- Keep terminal access through <C-\>, <F7>, and ToggleTerm commands,
    -- but remove AstroNvim's terminal submenu from the task menu.
    for _, suffix in ipairs { "f", "h", "v", "l", "n", "u", "t", "p" } do
      opts.mappings.n["<Leader>t" .. suffix] = nil
    end
  end,
}
