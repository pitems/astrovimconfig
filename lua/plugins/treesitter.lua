-- Remove this line if it's still there
-- if true then return {} end

---@type LazySpec
return {
  {
    "neovim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = { "neovim-treesitter/treesitter-parser-registry" },
    config = function()
      require("nvim-treesitter").setup()

      local query = require "vim.treesitter.query"
      local nvim_treesitter_configs = require "nvim-treesitter.configs"
      local directive_opts = vim.fn.has "nvim-0.10" == 1 and { force = true, all = false } or true

      local function capture_node(match, capture_id)
        local node = match[capture_id]
        if type(node) == "table" then
          node = node[1]
        end
        if node and type(node.range) == "function" then
          return node
        end
      end

      local function capture_text(match, bufnr, capture_id, metadata)
        local node = capture_node(match, capture_id)
        if not node then
          return
        end
        if metadata then
          return vim.treesitter.get_node_text(node, bufnr, { metadata = metadata }) or ""
        end
        return vim.treesitter.get_node_text(node, bufnr) or ""
      end

      local function get_parser_from_markdown_info_string(injection_alias)
        local match = vim.filetype.match { filename = "a." .. injection_alias }
        return match or ({ ex = "elixir", pl = "perl", sh = "bash", uxn = "uxntal", ts = "typescript" })[injection_alias] or injection_alias
      end

      query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
        metadata = metadata or {}
        local type_attr_value = capture_text(match, bufnr, pred[2])
        if not type_attr_value then
          return
        end
        local configured = ({ importmap = "json", module = "javascript", ["application/ecmascript"] = "javascript", ["text/ecmascript"] = "javascript" })[type_attr_value]
        if configured then
          metadata["injection.language"] = configured
        else
          local parts = vim.split(type_attr_value, "/", {})
          metadata["injection.language"] = parts[#parts]
        end
      end, directive_opts)

      query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
        metadata = metadata or {}
        local injection_alias = capture_text(match, bufnr, pred[2])
        if not injection_alias then
          return
        end
        metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias:lower())
      end, directive_opts)

      query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
        metadata = metadata or {}
        local id = pred[2]
        local text = capture_text(match, bufnr, id, metadata and metadata[id]) or ""
        if not metadata[id] then
          metadata[id] = {}
        end
        metadata[id].text = string.lower(text)
      end, directive_opts)

      local install_langs = {
        "bash",
        "c",
        "css",
        "html",
        "javascript",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
      }
      local ft_langs = {
        "bash",
        "c",
        "css",
        "html",
        "javascript",
        "python",
        "query",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
      }

      nvim_treesitter_configs.setup {
        ensure_installed = install_langs,
        auto_install = false,
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = ft_langs,
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.bo[args.buf].indentexpr = "nvim_treesitter#indent()"
        end,
      })
    end,
  },
}
