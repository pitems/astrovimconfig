local M = {}

local ns = vim.api.nvim_create_namespace "htmlhint"
local timers = {}

local function get_timer(bufnr)
  local timer = timers[bufnr]
  if timer then
    timer:stop()
    timer:close()
  end

  timer = vim.uv.new_timer()
  timers[bufnr] = timer
  return timer
end

local function publish(bufnr, diagnostics)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.diagnostic.set(ns, bufnr, diagnostics, {
    severity_sort = true,
    virtual_text = true,
    underline = true,
    signs = true,
  })
end

local function clear(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.diagnostic.reset(ns, bufnr)
  end
end

local function build_diagnostics(stdout)
  local ok, decoded = pcall(vim.json.decode, stdout)
  if not ok or type(decoded) ~= "table" then
    return nil, "htmlhint returned invalid JSON"
  end

  local diagnostics = {}

  for _, result in ipairs(decoded) do
    for _, message in ipairs(result.messages or {}) do
      local line = tonumber(message.line) or 1
      local col = tonumber(message.col) or 1
      local severity = vim.diagnostic.severity.ERROR

      if message.type == "warning" then
        severity = vim.diagnostic.severity.WARN
      end

      diagnostics[#diagnostics + 1] = {
        lnum = line - 1,
        col = math.max(col - 1, 0),
        end_lnum = line - 1,
        end_col = math.max(col, 0),
        severity = severity,
        source = "htmlhint",
        message = message.message or "HTMLHint diagnostic",
      }
    end
  end

  return diagnostics
end

local function run(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if vim.bo[bufnr].filetype ~= "html" then
    clear(bufnr)
    return
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    clear(bufnr)
    return
  end

  local result = vim.system({ "htmlhint", "-f", "json", filename }, { text = true }):wait()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local diagnostics, err = build_diagnostics(result.stdout or "")
  if diagnostics then
    publish(bufnr, diagnostics)
  else
    clear(bufnr)
    if err then
      vim.notify(err, vim.log.levels.WARN)
    end
  end
end

function M.schedule(bufnr, delay_ms)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  delay_ms = delay_ms or 200

  local timer = get_timer(bufnr)
  timer:start(delay_ms, 0, vim.schedule_wrap(function()
    timers[bufnr] = nil
    run(bufnr)
  end))
end

function M.clear(bufnr)
  clear(bufnr or vim.api.nvim_get_current_buf())
end

return M
