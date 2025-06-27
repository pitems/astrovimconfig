-- Auto Complete config 
return {
  "hrsh7th/nvim-cmp",
  dependencies = { "L3MON4D3/LuaSnip" }, -- Ensure LuaSnip is loaded
  opts = function(_, opts)
    local cmp = require("cmp")
    local luasnip = require("luasnip")


    cmp.setup({
      snippet = {
        expand = function(args)
          -- Use LuaSnip to expand snippets
          require("luasnip").lsp_expand(args.body)
        end,
      },
      sources = {
        -- { name = "nvim_lsp" },
        { name = "luasnip", keyword_length = 2 },  -- Only LuaSnip for snippets
      },
   -- formatting = {
   --      fields = { "abbr", "kind", "menu" }, -- Only show abbreviation, kind, and menu fields
   --      format = function(entry, vim_item)
   --        -- Customize the appearance of completion items
   --        vim_item.kind = vim.lsp.protocol.CompletionItemKind[vim_item.kind]
   --        
   --        -- You can also remove documentation or other extra fields if they are shown
   --        vim_item.menu = "(" .. entry.source.name .. ")"
   --
   --        -- Return the formatted item
   --        return vim_item
   --      end,
   --      expandable_indicator = true
   --    },
    })

    opts.snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body) -- Use LuaSnip to expand snippets
        end,
      }
    -- Add Dart-specific source
    opts.sources = cmp.config.sources(vim.list_extend(opts.sources or {}, {
      -- { name = "nvim_lsp" }, -- Ensure LSP completions are enabled
      -- { name = "luasnip",keyword_length = 2 },  -- For snippets { name = "buffer" },   -- Buffer completions
      { name = "path" },     -- Path completions
    }))
    

    opts.mapping = cmp.mapping.preset.insert({
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()  -- Only select next item
        else
          fallback()  -- Trigger the default behavior (like inserting a tab character)
        end
      end),
      ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Select previous item
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),      -- Scroll docs up
      ["<C-f>"] = cmp.mapping.scroll_docs(4),       -- Scroll docs down
      ["<C-Space>"] = cmp.mapping.complete(),       -- Trigger completion manually
      ["<C-e>"] = cmp.mapping.abort(),              -- Abort completion
      ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm selected item
    })

    return opts
  end,
}
