local M = {}

local function doc_path_for(source_path)
  local project_root = vim.fn.getcwd()
  local rel = source_path:gsub(project_root .. "/", "")
  return project_root
    .. "/documentation/"
    .. rel:gsub("%.%w+$", ".md")
end

local function write_doc_file(doc_path, lines)
  vim.fn.writefile(lines, doc_path)

  local doc_buf = vim.fn.bufnr(doc_path)
  if doc_buf ~= -1 and vim.api.nvim_buf_is_loaded(doc_buf) then
    vim.api.nvim_buf_set_lines(doc_buf, 0, -1, false, lines)
    vim.bo[doc_buf].modified = false
  end
end

local function read_file_lines(path)
  if not vim.loop.fs_stat(path) then
    return nil
  end
  return vim.fn.readfile(path)
end

local function join_lines(lines)
  return table.concat(lines, "\n")
end

local function normalize_text(text)
  return (text:gsub("\r?\n+$", ""))
end

local function render_documentation(source_path, doc_path, filetype)
  local project_root = vim.fn.getcwd()
  local code, stdout, stderr = require("documentation.cli_bridge").render_documentation({
    source = source_path,
    doc_path = doc_path,
    filetype = filetype,
    project_root = project_root,
  })

  if code ~= 0 then
    local message = stderr ~= "" and stderr or stdout ~= "" and stdout or "Failed to render documentation"
    error(message)
  end

  return stdout
end

function M.sync_from_source_buffer(source_buf)
  local source_path = vim.api.nvim_buf_get_name(source_buf)
  if source_path == "" then return end

  local doc_path = doc_path_for(source_path)
  local current = read_file_lines(doc_path)
  if not current then
    return
  end

  local filetype = vim.bo[source_buf].filetype
  local rendered = render_documentation(source_path, doc_path, filetype)
  if rendered == "" then
    return
  end

  local normalized = normalize_text(rendered)
  local updated = vim.split(normalized, "\n", { plain = true })
  if normalized == join_lines(current) then
    return
  end

  write_doc_file(doc_path, updated)
end

function M.open_or_create_doc()
  local source_buf = vim.api.nvim_get_current_buf()
  local source_path = vim.api.nvim_buf_get_name(source_buf)
  if source_path == "" then return end

  local doc_path = doc_path_for(source_path)

  local filetype = vim.bo[source_buf].filetype

  if vim.loop.fs_stat(doc_path) then
    local current = read_file_lines(doc_path)
    if not current then
      vim.cmd("edit " .. vim.fn.fnameescape(doc_path))
      return
    end

    local rendered = render_documentation(source_path, doc_path, filetype)
    local updated = vim.split(normalize_text(rendered), "\n", { plain = true })

    if normalize_text(rendered) ~= join_lines(current) then
      vim.notify(
        "Documentation changed for " .. vim.fn.fnamemodify(source_path, ":t") .. ". Updating and opening the refreshed doc.",
        vim.log.levels.INFO
      )
      write_doc_file(doc_path, updated)
    end

    vim.cmd("edit " .. vim.fn.fnameescape(doc_path))
    return
  end

  local choice = vim.fn.confirm("Create documentation file?", "&Yes\n&No", 2)
  if choice ~= 1 then
    return
  end

  vim.fn.mkdir(vim.fn.fnamemodify(doc_path, ":h"), "p")
  local rendered = render_documentation(source_path, doc_path, filetype)
  local md_lines = vim.split(normalize_text(rendered), "\n", { plain = true })
  write_doc_file(doc_path, md_lines)
  vim.cmd("edit " .. vim.fn.fnameescape(doc_path))
end

return M
