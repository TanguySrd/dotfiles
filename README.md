# dotfiles

My macOS dotfiles, managed as a **bare git repository** with the work tree pointed at `$HOME`. The repo tracks shell, terminal, editor and window-manager configuration, with a unified light/dark theme that switches at runtime across WezTerm, tmux and Neovim.

## Contents

| Area | File(s) | Tool |
|------|---------|------|
| Shell | `.zshrc`, `.p10k.zsh` | zsh + Powerlevel10k |
| Terminal | `.wezterm.lua` | WezTerm |
| Multiplexer | `.tmux.conf`, `.config/tmux/themes/` | tmux |
| Editor | `.config/nvim/` | Neovim |
| Window manager | `.config/yabai/yabairc` | yabai |
| Hotkeys | `.config/skhd/skhdrc` | skhd |
| Theme switcher | `.local/bin/theme`, `.config/theme/current` | custom |

## How this repo works

The dotfiles live in a bare repo at `~/.cfg` whose work tree is `$HOME`. Instead of `git`, a `config` alias (defined in `.zshrc`) operates on it:

```sh
alias config='/usr/bin/git --git-dir=/Users/tanguyserrand/.cfg/ --work-tree=/Users/tanguyserrand'
```

So you manage dotfiles from anywhere with, for example, `config status`, `config add .zshrc`, `config commit`, `config push`. Untracked files are hidden (`status.showUntrackedFiles no`) so `config status` only shows tracked dotfiles, not your whole home directory.

### Install on a new machine

```sh
git clone --bare git@github.com:TanguySrd/dotfiles.git "$HOME/.cfg"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout                                  # back up any conflicting files first
config config --local status.showUntrackedFiles no
```

Then install the dependencies listed at the bottom of this file.

## Theming (light / dark)

All three tools read a single source of truth: the file `~/.config/theme/current`, which contains either `light` or `dark` (it defaults to `light` if missing). This file is intentionally **not tracked**, since the active theme is per machine.

### Switching

Two entry points, both keep all tools in sync:

```sh
theme            # print the current theme
theme light      # switch to light
theme dark       # switch to dark
theme toggle     # flip
```

```vim
:Theme           " print the current theme (inside Neovim)
:Theme light
:Theme dark
:Theme toggle
```

### What applies, and when

| Tool | How it reads the theme | When it applies |
|------|------------------------|-----------------|
| WezTerm | `.wezterm.lua` reads `~/.config/theme/current` and picks a color table | Live. The switch touches `~/.wezterm.lua`, and WezTerm reloads its own config on change |
| tmux | `.tmux.conf` uses `if-shell` to `source-file` `themes/light.conf` or `themes/dark.conf` | Live, on `tmux source-file` |
| Neovim | `tunis.core.theme` reads the file; used by colorscheme, `background`, and lualine | On launch, or live via `:Theme` |

The `theme` shell command writes the file, re-sources tmux on every running server, and touches the WezTerm config to force a reload. A running Neovim does not react to the shell command (a shell cannot reach into nvim's state), so use `:Theme` inside Neovim. `:Theme` itself also re-sources tmux and touches WezTerm, so it is a full switch too.

### Adding or editing a theme

- **WezTerm**: edit the `themes` table in `.wezterm.lua` (each entry has `colors`, plus optional `window_background_opacity` and `macos_window_background_blur`).
- **tmux**: edit `~/.config/tmux/themes/light.conf` or `dark.conf`.
- **Neovim**: the ayu colorscheme is driven by `tunis.core.theme.is_dark()` in `colorscheme.lua`, `core/options.lua` and `lualine.lua`.

The light theme is Ayu Light. The dark theme is Ayu Mirage in Neovim, with matching hand-written palettes for WezTerm and tmux (`#011423` background, `#CBE0F0` foreground, `#47FF9C` accent). Dark mode is also semi-transparent in WezTerm and Neovim.

## zsh (`.zshrc`)

- **Prompt**: Powerlevel10k (with instant prompt), configured by `.p10k.zsh`.
- **History**: shared across sessions, dedups, stored in `~/.zhistory`. Up/Down arrows do prefix history search.
- **Aliases**: `ls` runs `eza --icons`, and `config` manages this repo.
- **PATH**: adds Homebrew and `~/.local/bin` (where the `theme` script lives).
- **Plugins**: zsh-autosuggestions and zsh-syntax-highlighting from Homebrew. SDKMAN is initialised at the end of the file (required by SDKMAN).

## WezTerm (`.wezterm.lua`)

MesloLGS Nerd Font at size 16, no tab bar, `RESIZE` window decorations, small top padding. Colors come from the active theme (see Theming). The config watches `~/.config/theme/current` and reloads on change.

## tmux (`.tmux.conf`)

- **Prefix**: remapped to `C-a`.
- **Splits**: `prefix |` splits vertically, `prefix -` splits horizontally, both keeping the current path. `prefix m` zooms a pane.
- **Copy mode**: vi keys. `v` starts a selection, `y` yanks. Double-click selects a word and stays in copy mode (it does not auto-copy); press `y` to yank.
- **Mouse**: on.
- **Navigation**: smart pane switching with Neovim splits via `smart-splits.nvim` (`Alt + h/j/k/l`), and pane resize with `prefix + h/j/k/l`.
- **Plugins** (via tpm): `tmux-resurrect` and `tmux-continuum` persist and auto-restore sessions.
- **Theme**: sourced from `~/.config/tmux/themes/` based on the active theme.

## Neovim (`.config/nvim/`)

A Lua configuration under the `tunis` namespace, using **lazy.nvim** as the plugin manager.

- `init.lua` loads `tunis.core`, then `tunis.lazy`, then `tunis.lsp`.
- `core/` holds `options.lua`, `keymaps.lua` (leader is Space) and `theme.lua` (the shared theme module and `:Theme` command).
- `plugins/` holds one file per plugin. Highlights: Telescope, nvim-tree, Treesitter, nvim-cmp, LSP via lspconfig and Mason, conform (formatting), nvim-lint (linting), gitsigns, lualine, bufferline, noice, which-key, trouble, todo-comments, alpha (dashboard), auto-session, lazygit, nvim-dap (debugging) and nvim-jdtls (Java, see `ftplugin/java.lua`).
- `lazy-lock.json` pins plugin versions. `.stylua.toml` configures Lua formatting.

A few leader keybinds: `<leader>nh` clears search highlights, `<leader>sv` / `<leader>sh` split, `<leader>to` / `<leader>tx` open/close tabs.

## yabai (`.config/yabai/yabairc`)

Tiling window manager: `bsp` layout, 23px padding and gaps everywhere. `alt` is the mouse modifier (drag to move, right-drag to resize). System Settings, Calculator, Spotify, Messages and Picture in Picture float instead of tiling.

## skhd (`.config/skhd/skhdrc`)

Hotkey daemon driving yabai:

- `shift + alt + h/j/k/l`: focus window in a direction.
- `ctrl + alt + h/j/k/l`: move (warp) window.
- `shift + alt + r / y / x`: rotate and mirror the layout.
- `shift + alt + t`: toggle float, `shift + alt + m`: fullscreen zoom, `shift + alt + e`: balance.
- `shift + alt + 1..7`: send window to a space, `shift + alt + p/n`: previous/next space.
- `alt + s / g`: focus display north/south.

## Dependencies

Install with Homebrew unless noted:

- **Shell**: `powerlevel10k`, `eza`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
- **Terminal/multiplexer**: `wezterm`, `tmux`, plus [tpm](https://github.com/tmux-plugins/tpm) at `~/.tmux/plugins/tpm`
- **Editor**: `neovim` (lazy.nvim bootstraps itself on first launch)
- **Window management**: `yabai`, `skhd`
- **Toolchains**: [SDKMAN](https://sdkman.io/) at `~/.sdkman`
- **Font**: MesloLGS Nerd Font

## Branches

- `main`: the current setup with both themes.
- `nvim-config`: a separate snapshot of the Neovim configuration.
