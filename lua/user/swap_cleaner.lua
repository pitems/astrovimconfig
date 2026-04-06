return {
  {
    name= "swap-cleaner",
    lazy = false,
    config = function()

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.fn.system([[find ~/.local/state/nvim/swap -name "*.swp" -mtime +1 -delete]])
        end,
      })
    end,
          vim.api.nvim_create_user_command("FuckSwapSafe", function()
        vim.fn.system([[find ~/.local/state/nvim/swap -name "*.swp" -mtime +1 -delete]])
        print("🔥 Old swap files cleaned (safe)")
      end, {}),

vim.api.nvim_create_user_command("FuckSwapSmart", function()
  local swap_dir = vim.fn.stdpath("state") .. "/swap"

  -- 🔍 Quick check: are there any swap files at all?
  local check = vim.fn.glob(swap_dir .. "/*.swp")
  if check == "" then
    print("✅ No swap files found")
    return
  end

  print("🔍 Checking swap files...")

  local handle = io.popen('ls "' .. swap_dir .. '"/*.swp 2>/dev/null')
  if not handle then
    print("❌ Failed to read swap directory")
    return
  end

  local removed = 0
  local kept = 0

  for file in handle:lines() do
    -- extract PID
    local pid_cmd = 'strings "' .. file .. '" | grep -m1 "process ID" | grep -o "[0-9]\\+"'
    local pid_handle = io.popen(pid_cmd)
    local pid = pid_handle:read("*l")
    pid_handle:close()

    if pid then
      -- check if process exists
      local alive = os.execute("kill -0 " .. pid .. " 2>/dev/null")

      if alive ~= 0 then
        os.remove(file)
        removed = removed + 1
      else
        kept = kept + 1
      end
    else
      -- no PID → remove
      os.remove(file)
      removed = removed + 1
    end
  end

  handle:close()

  print(string.format("🧹 Removed: %d | ⚠️ Active: %d", removed, kept))
end, {})
  },
}
