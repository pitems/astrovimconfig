# Plugin guide

This is a quick reference for the plugins configured in `lua/plugins/`.
The descriptions reflect the current configuration, including the main keybindings and commands where they are defined.

## Navigation, search, and files

| Plugin | What it does | Main entry points |
| --- | --- | --- |
| [Telescope](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder for files, text, buffers, help, and plugin pickers. | `<leader>ff` files, `<leader>fg` grep, `<leader>fb` buffers, `<leader>fh` help |
| [Yazi](https://github.com/mikavilpas/yazi.nvim) | Opens the Yazi terminal file manager. | `<leader>yy` |
| [Harpoon](https://github.com/ThePrimeagen/harpoon) | Keeps a small list of important files for quick navigation. | `<leader>H` group; `Ha` add, `Hd` remove, `Hm` menu, `Hp`/`Hn` previous/next |
| [Flash](https://github.com/folke/flash.nvim) | Fast jump and Treesitter-aware motion. | `s`, `S`, operator-pending `r`/`R` |
| [Aerial](https://github.com/stevearc/aerial.nvim) | Symbol outline for the current file. | `<leader>o` |
| [Trouble](https://github.com/folke/trouble.nvim) | Lists diagnostics, symbols, location lists, and quickfix items. | `<leader>xx`, `<leader>xX`, `<leader>cs`, `<leader>cl`, `<leader>xL`, `<leader>xQ` |
| [Scope](https://github.com/tiagovla/scope.nvim) | Keeps buffers organized by tab. | Used by the tab and buffer-group configuration |

## Editing and language support

| Plugin | What it does |
| --- | --- |
| [Treesitter](https://github.com/neovim-treesitter/nvim-treesitter) | Syntax parsing, highlighting, indentation, and language-aware structure. |
| Treesitter Textobjects | Adds syntax-aware selection and movement around code objects. |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) + friendly-snippets | Expansible snippets, including Flutter/Dart snippets. |
| [Emmet](https://github.com/mattn/emmet-vim) | Expands HTML/CSS abbreviations in web-related filetypes. |
| [mini.surround](https://github.com/echasnovski/mini.surround) | Adds, deletes, and changes surrounding characters or tags. |
| [none-ls](https://github.com/nvimtools/none-ls.nvim) | Exposes formatters and linters through the LSP interface. |
| [Mason Tool Installer](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Installs configured language servers, formatters, debuggers, and Treesitter CLI tools. |
| AstroLSP | AstroNvim’s LSP setup, including the project’s Vue, TypeScript, and language-server customizations. |
| [lsp-signature](https://github.com/ray-x/lsp_signature.nvim) | Shows function signature help while typing. |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Completion framework and completion sources. It is configured through the AstroNvim/user setup. |
| [Hardtime](https://github.com/m4xshen/hardtime.nvim) | Helps detect and discourage inefficient Vim motions. |
| [dotenv](https://github.com/ellisonleao/dotenv.nvim) | Loads `.env` values into the Neovim process. |

## Notes, planning, and writing

| Plugin | What it does | Main entry points |
| --- | --- | --- |
| [Telekasten](https://github.com/renerocksai/telekasten.nvim) | Note-taking and vault navigation for Markdown notes. | `<leader>z` group; `zn` new note, `zz` panel, `zf` find, `zg` grep, `zd` today, `zc` calendar, `zb` backlinks, `zt` TODO |
| [Markview](https://github.com/OXY2DEV/markview.nvim) | Renders Markdown in a styled in-editor view. | Markview commands and configured file behavior |
| [Markdown Preview](https://github.com/selimacerbas/markdown-preview.nvim) | Provides a browser preview for Markdown. | Plugin commands |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Renders Markdown headings, bullets, code blocks, and other structures inside Neovim. | Automatic Markdown rendering |
| [Dooing](https://github.com/atiladefreitas/dooing) | Todo list with due dates, estimates, priorities, and completion state. | `<leader>td` global, `<leader>tD` project, `<leader>tN` due items |
| [Bloocky](https://github.com/atiladefreitas/bloocky) | Time-blocking calendar with day, week, and month views. It reads Dooing todos when they have due dates. | `<leader>tb`, `<leader>tB`, `:Bloocky`, `:BloockyAdd` |
| [Super Kanban](https://github.com/hasansujon786/super-kanban.nvim) | Markdown-backed Kanban boards. | `<leader>kk` create/open board, `<leader>kK` open board |

## Flutter and development workflow

| Plugin | What it does |
| --- | --- |
| [flutter-tools.nvim](https://github.com/nvim-flutter/flutter-tools.nvim) | Flutter run, reload, devices, emulators, outline, and debugger integration. |
| [flutter-bloc.nvim](https://github.com/wa11breaker/flutter-bloc.nvim) | Flutter BLoC/Cubit scaffolding and helpers. |
| [git-conflict.nvim](https://github.com/akinsho/git-conflict.nvim) | Helps inspect and resolve Git merge conflicts. |
| [vscode-diff.nvim](https://github.com/esmuellert/vscode-diff.nvim) | Opens diffs using a VS Code-style presentation. |
| [ToggleTerm](https://github.com/akinsho/toggleterm.nvim) | Floating and split terminal management. | `<C-\>` floating terminal |
| [Codex.nvim](https://github.com/kkrampis/codex.nvim) | Opens the Codex interface inside Neovim. | `<C-;>` |
| [calendar-vim](https://github.com/mattn/calendar-vim) | Calendar interface for date-oriented workflows. | Calendar commands |

## UI and appearance

| Plugin | What it does |
| --- | --- |
| AstroUI | AstroNvim UI defaults and customization layer. |
| [Heirline](https://github.com/rebelot/heirline.nvim) | Statusline components, including the active buffer-group name. |
| [Bufferline](https://github.com/akinsho/bufferline.nvim) | Tab-like buffer display and pinned-buffer groups. |
| [mini.icons](https://github.com/nvim-mini/mini.icons) | Provides icons used by UI and file-related plugins. |
| [colourful-winsep](https://github.com/nvim-zh/colorful-winsep.nvim) | Adds colored separators between windows. |
| [Zen Mode](https://github.com/folke/zen-mode.nvim) | Focused writing/editing layout. | `<leader>Z` |
| [Themery](https://github.com/ly5250/themery.nvim) | Theme switching support. |
| TokyoNight and Koda | Colorschemes available in the theme configuration. |
| Snacks | Shared UI utilities and the custom startup dashboard/banner. |
| [presence.nvim](https://github.com/andweeb/presence.nvim) | Discord Rich Presence for the editor. |

## Configuration notes

- Files ending in `.bak` are backups, not active plugin specs: `nvim-cmp.lua.bak` and `themery.bak`.
- `astrocore.lua`, `astrolsp.lua`, and `astroui.lua` are configuration modules rather than standalone third-party plugins.
- `nvim-nio` is a support dependency used by other Neovim plugins.
- The `<leader>z` title is registered in `lua/keybinds/groups/telekasten.lua`, while Telekasten’s actual lazy-loaded mappings remain in `lua/plugins/telekasten.lua`.
