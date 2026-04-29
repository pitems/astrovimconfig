# Neovim Migration Checklist

Use this when setting up this config on a new Mac.

## Git Branches

- Current complete config is on `flutter_fix`.
- Local `main` has also been fast-forwarded to the same commit as `flutter_fix`.
- `origin/flutter_fix` is up to date.
- `origin/main` is still old until you run:

```bash
git push origin main
```

Before pushing `main`, confirm secrets are not tracked. `.env` is ignored and should stay local only.

## Clone Location

Expected config path:

```bash
~/.config/nvim
```

Clone with:

```bash
git clone git@github.com:pitems/astrovimconfig.git ~/.config/nvim
cd ~/.config/nvim
git switch flutter_fix
```

If you push `main`, you can use `main` instead.

## Required System Tools

Install or verify these first:

```bash
brew install neovim git ripgrep fd fzf yazi tree-sitter
```

Also install:

- `colorscript`, used by the dashboard banner.
- A Nerd Font, because the config uses icons heavily.
- `node` and `npm`, recommended through `nvm`.
- `python3` and `pip3`, recommended through `pyenv` or Homebrew.

Current machine paths show these are in use:

- `nvim`
- `git`
- `rg`
- `fd`
- `fzf`
- `yazi`
- `colorscript`
- `flutter`
- `dart`
- `fvm`
- `node`
- `npm`
- `python3`
- `pip3`
- `tree-sitter`
- `codex`

## Flutter And Dart

This config uses `nvim-flutter/flutter-tools.nvim` with `fvm = true`.

Install:

```bash
brew tap leoafarias/fvm
brew install fvm
```

Then install Flutter through FVM or make sure your existing Flutter SDK is on `PATH`:

```bash
fvm install stable
fvm global stable
flutter doctor
```

Check:

```bash
which flutter
which dart
which fvm
flutter doctor
```

## AI Tools

### Codex

This config uses `kkrampis/codex.nvim`.

The plugin has `autoinstall = true`, but installing Codex yourself is safer:

```bash
npm install -g @openai/codex
codex --version
```

Make sure your OpenAI/Codex auth is set up on the new machine.

## Mason / Neovim Tooling

On first Neovim launch, lazy.nvim should install plugins automatically.

Inside Neovim, run:

```vim
:Lazy sync
:Mason
```

Install/check these Mason tools if needed:

- `lua-language-server`
- `stylua`
- `debugpy`
- `tree-sitter-cli`

Note: `lua/plugins/mason.lua` is currently disabled with:

```lua
if true then return {} end
```

So Mason auto-install from that file will not run unless that line is removed.

## Markdown / Notes

Telekasten expects notes under:

```text
~/notes
~/notes/daily
~/notes/weekly
~/notes/templates
~/notes/programming/flutter
```

Create them if you use notes:

```bash
mkdir -p ~/notes/daily ~/notes/weekly ~/notes/templates ~/notes/programming/flutter
```

There is likely a typo in the Rust vault path:

```lua
home .. "~/programming/rust"
```

Review `lua/plugins/telekasten.lua` before relying on the Rust vault.

## Debugging

Flutter debugging uses:

- `nvim-dap`
- `nvim-dap-ui`
- `.vscode/launch.json`, if present in a Flutter project

For Python debugging, install/check Mason `debugpy`.

## Files Not Currently Tracked

These are untracked right now and will not migrate through Git unless added:

```text
.nvimlog
test.md
```

`lazy-lock.json` is ignored by `.gitignore`, so plugin versions may resolve fresh on the new Mac.

## First Launch Checklist

1. Install Homebrew packages and language runtimes.
2. Clone the repo into `~/.config/nvim`.
3. Check out `flutter_fix` or updated `main`.
4. Set up Codex auth.
5. Run `nvim`.
6. Run `:Lazy sync`.
7. Run `:checkhealth`.
8. Open a Flutter project and run `:FlutterDevices`.
9. Run `flutter doctor` outside Neovim if Flutter commands fail.
