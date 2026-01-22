local M = {}

local cursor_hl_defined = false


-- function for settings the lines on the screen
local function build_lines(diff)
  local lines = {}
  -- Padding line (cursor lives here)
  table.insert(lines, "")

  table.insert(lines, "➕ Added (" .. #diff.new .. ")")
  for _, fn in ipairs(diff.new) do
    table.insert(lines, "  • " .. fn.name)
  end

  table.insert(lines, "")
  table.insert(lines, "🔁 Renamed (" .. #diff.renamed .. ")")
  for _, r in ipairs(diff.renamed) do
    table.insert(lines, "  • " .. r.from .. " → " .. r.to)
  end

  table.insert(lines, "")
  table.insert(lines, "⚠️ Deprecated (" .. #diff.removed .. ")")
  for _, fn in ipairs(diff.removed) do
    table.insert(lines, "  • " .. fn.name)
  end

  return lines
end

local function pad_line(text, width)
  local len = vim.fn.strdisplaywidth(text)
  if len >= width then
    return text
  end
  return text .. string.rep(" ", width - len)
end

-- function for opening the window
local function open_window(lines)
  local buf = vim.api.nvim_create_buf(false, true)

  -- Reserve space for footer (2 lines)
  local footer_lines = {
    "", -- divider
    "", -- actions
  }

  local all_lines = vim.list_extend(vim.deepcopy(lines), footer_lines)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, all_lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false


  local width = math.floor(vim.o.columns * 0.6)
  local height = math.min(#all_lines + 2, math.floor(vim.o.lines * 0.7))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    title = " Documentation Changes ",
    title_pos = "center",
    width = width,
    height = height,
    row = (vim.o.lines - height) / 2,
    col = (vim.o.columns - width) / 2,
  })
  
  vim.api.nvim_win_set_cursor(win, { 1, 0 })


  -- Conceal cursor
  vim.wo[win].conceallevel = 3
  vim.wo[win].concealcursor = "nvic"


  -- ── FOOTER ─────────────────────────────────────────────

  local footer_start = #all_lines - 2

  local divider = string.rep("─", width)
  local actions = pad_line(
    " [Enter] Apply     [Q] Cancel    ",
    width
  )

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, footer_start, footer_start + 2, false, {
    divider,
    actions,
  })
  vim.bo[buf].modifiable = false

  -- Use extmarks instead of deprecated highlight
  local ns = vim.api.nvim_create_namespace("doc_diff_footer")

  vim.api.nvim_buf_set_extmark(buf, ns, footer_start, 0, {
    end_col = width,
    hl_group = "Comment",
  })

  vim.api.nvim_buf_set_extmark(buf, ns, footer_start + 1, 0, {
    end_col = width,
    hl_group = "Comment",
  })

  return buf, win
end

local function add_cursor_sink(buf)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { " " })
  vim.bo[buf].modifiable = false
end

local function set_keymaps(buf, on_apply, on_cancel)
  local map = function(lhs, fn)
    vim.keymap.set("n", lhs, fn, { buffer = buf, silent = true })
  end

  vim.keymap.set("n", "<Up>", "<Nop>", { buffer = buf })
  vim.keymap.set("n", "<Down>", "<Nop>", { buffer = buf })
  vim.keymap.set("n", "k", "<Nop>", { buffer = buf })
  vim.keymap.set("n", "j", "<Nop>", { buffer = buf })

  map("q", on_cancel)
  map("<Esc>", on_cancel)
  -- map("a", on_apply)
  map("<CR>", on_apply)
end

--- Shows a floating preview window
--- @param diff table { new, renamed, removed }
--- @param on_apply function
--- @param on_cancel function|nil
function M.open(diff, on_apply, on_cancel)

  local prev_cursor = vim.o.guicursor

  vim.api.nvim_set_hl(0, "CursorInvisible", { blend = 100 })
  vim.o.guicursor = "a:CursorInvisible"



  local lines = build_lines(diff)
  local buf, win = open_window(lines)

  local function cleanup()
    vim.o.guicursor = prev_cursor
  end

  set_keymaps(buf,
    function()
      cleanup()
      vim.api.nvim_win_close(win, true)
      on_apply()
    end,
    function()
      cleanup()
      vim.api.nvim_win_close(win, true)
      if on_cancel then on_cancel() end
    end
  )
end

return M
