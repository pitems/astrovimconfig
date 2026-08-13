# Yazi quick reference

Yazi is the terminal file manager integrated into this Neovim configuration.

## Open Yazi

| Shortcut | Action |
| --- | --- |
| `<leader>Y` | Open Yazi at the current file |
| `:Yazi` | Open Yazi with a command |
| `<F1>` | Show the complete help screen |
| `q` | Quit Yazi |

## Navigate

| Key | Action |
| --- | --- |
| `h` / `←` | Go to the parent directory |
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `l` / `→` / `<Enter>` | Enter a directory or open a file |
| `gg` | Go to the top |
| `G` | Go to the bottom |
| `.` | Show/hide hidden files |
| `z` | Jump to a directory or file |
| `Z` | Jump using zoxide |

## Select and manage files

| Key | Action |
| --- | --- |
| `<Space>` | Select/unselect the hovered item |
| `v` | Enter visual selection mode |
| `<Esc>` | Cancel selection |
| `a` | Create a file; end the name with `/` for a directory |
| `r` | Rename |
| `y` | Copy selected files |
| `x` | Cut selected files |
| `p` | Paste copied/cut files |
| `d` | Move selected files to trash |
| `D` | Permanently delete selected files |
| `o` / `<Enter>` | Open selected files |

## Copy paths

These are sequential commands: press `c`, then the second key.

| Shortcut | Action |
| --- | --- |
| `cc` | Copy the full path |
| `cd` | Copy the directory path |
| `cf` | Copy the filename |
| `cn` | Copy the filename without its extension |

## Search and filter

| Key | Action |
| --- | --- |
| `f` | Filter the current file list |
| `/` | Find the next matching file |
| `?` | Find the previous matching file |
| `s` | Search files by name |
| `S` | Search file contents with ripgrep |

## Yazi.nvim shortcuts

These are handled by the Neovim integration while the Yazi window is focused:

| Shortcut | Action |
| --- | --- |
| `<C-v>` | Open selected files in vertical splits |
| `<C-x>` | Open selected files in horizontal splits |
| `<C-t>` | Open selected files in new tabs |
| `<C-q>` | Send selected files to the quickfix list |
| `<C-y>` | Copy selected files' relative paths |
| `<Tab>` | Cycle through open Neovim buffers |

## Useful mental model

1. Move to a file with `h/j/k/l`.
2. Press `<Enter>` to open it in Neovim.
3. Use `<Space>` to select multiple files.
4. Use `<C-v>`, `<C-x>`, or `<C-t>` to choose how selected files open.
5. Press `<F1>` whenever you forget a command.

Official documentation: <https://yazi-rs.github.io/docs/quick-start/>
