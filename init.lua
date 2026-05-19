-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)
vim.g.snacks_scope = false

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end
require "lazy_setup"
require "polish"
require "user.swap_cleaner"
require("utils.transparent").setup {
  enabled = false, -- start disabled
}
--- Config for session manager groups
require("resession").setup {
  autosave = { enabled = false },
  dirs = {
    project = function() return vim.fn.getcwd() .. "/.nvim/sessions" end,
  },
}

require("core.buffer_groups").setup()

for _, autocmd in ipairs(require("user.autocmds")) do
  vim.api.nvim_create_autocmd(autocmd.event, {
    desc = autocmd.desc,
    callback = autocmd.callback,
    pattern = autocmd.pattern,
    group = autocmd.group,
  })
end

do
  -- Neovim 0.12's built-in markdown ftplugin unconditionally calls
  -- `vim.treesitter.start()`. If the installed markdown parser is stale or
  -- built for the wrong architecture, opening a markdown buffer hard-fails.
  -- Keep markdown usable and let the parser be rebuilt separately.
  local ts_start = vim.treesitter.start
  vim.treesitter.start = function(bufnr, lang)
    bufnr = vim._resolve_bufnr(bufnr)
    lang = lang or vim.bo[bufnr].filetype

    if lang == "markdown" then
      local ok = pcall(vim.treesitter.get_parser, bufnr, lang)
      if not ok then
        return
      end
    end

    return ts_start(bufnr, lang)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gpchat",
  callback = function()
    -- ENTER in insert mode sends message
    vim.keymap.set("i", "<CR>", "<Esc>:GpChatRespond<CR>", { buffer = true })

    -- OPTIONAL: Shift+Enter = newline
    vim.keymap.set("i", "<S-CR>", "<CR>", { buffer = true })

    -- OPTIONAL: normal mode enter also works
    vim.keymap.set("n", "<CR>", ":GpChatRespond<CR>", { buffer = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 80
  end,
})

vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = { "*.md", "*.markdown", "*.mdx", "*.mkd" },
  callback = function()
    vim.b.snacks_scope = false
  end,
})

local function copy_relative_path()
  local path = vim.fn.expand "%:."

  vim.fn.setreg("+", path)
  vim.fn.setreg("*", path)

  vim.notify("Copied for Codex: " .. path, vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>rp", copy_relative_path, {
  desc = "Copy relative path for Codex",
  noremap = true,
  silent = false,
})

vim.keymap.set("n", "yr", copy_relative_path, {
  desc = "Yank relative path",
  noremap = true,
  silent = false,
})
