local M = {}

local function cli_root()
  return vim.fn.stdpath("config") .. "/tools/documentation_cli"
end

local function cli_binary()
  local binary = cli_root() .. "/build/documentation_cli_v1"
  if vim.fn.executable(binary) == 1 then
    return binary
  end

  return nil
end

local function run_cli(args)
  local command = {}
  local binary = cli_binary()
  if binary then
    command = { binary }
  else
    command = { "dart", "run", "bin/documentation_cli.dart" }
  end
  vim.list_extend(command, args)

  if vim.system then
    local result = vim.system(command, {
      cwd = cli_root(),
      text = true,
    }):wait()

    return result.code, result.stdout or "", result.stderr or ""
  end

  local output = vim.fn.system(command)
  local code = vim.v.shell_error
  return code, output, ""
end

function M.render_block(kind, opts)
  opts = opts or {}

  local args = {
    "blocks",
    "--kind",
    kind,
  }

  if opts.name and opts.name ~= "" then
    vim.list_extend(args, { "--name", opts.name })
  end

  if opts.signature and opts.signature ~= "" then
    vim.list_extend(args, { "--signature", opts.signature })
  end

  if opts.intro and opts.intro ~= "" then
    vim.list_extend(args, { "--intro", opts.intro })
  end

  local code, stdout, stderr = run_cli(args)
  if code ~= 0 then
    error((stderr ~= "" and stderr or stdout ~= "" and stdout or "Failed to render note block"))
  end

  return stdout
end

function M.insert_block(kind, opts)
  local ft = vim.bo.filetype
  if ft ~= "markdown" and ft ~= "md" then
    vim.notify("Note blocks are meant for markdown documentation buffers", vim.log.levels.WARN)
    return
  end

  local snippet = M.render_block(kind, opts)
  local lines = vim.split(snippet, "\n", { plain = true })
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]

  vim.api.nvim_buf_set_lines(0, row, row, false, lines)
end

function M.insert_context_block(kind)
  local line = vim.api.nvim_get_current_line():gsub("^%s+", ""):gsub("%s+$", "")
  local opts = {}

  if kind == "class" then
    opts.name = line:match("^###%s+(.+)$") or nil
  elseif kind == "function" or kind == "variable" or kind == "constructor" then
    opts.signature = line:match("^#####%s+(.+)$") or nil
  end

  M.insert_block(kind, opts)
end

return M
