-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
if vim.g.neovide then
  vim.o.guifont = "Maple Mono:h14" -- Change size as needed
end
-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
--
-- Reapply the selected colorscheme after all startup plugins have initialized.
-- Some UI plugins load their default highlights after AstroUI selects the
-- colorscheme during setup.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    require("user.theme-hub").reapply()
  end,
})

-- local ok, resession = pcall(require, "resession")
-- if ok then
--   resession.setup {
--     autosave = { enabled = false },
--     dirs = {
--       project = function() return vim.fn.getcwd() .. "/.nvim/sessions" end,
--     },
--   }
--
--   -- vim.notify("Resession initialized at: " .. vim.fn.getcwd() .. "/.nvim/sessions")
-- end
