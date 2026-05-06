# 🛠️ My Neovim Config

A modern, modular Neovim configuration written in **Lua**, focused on performance, convenience, and an enjoyable coding experience.

> ⚡ Powered by [Lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager.

![фото](media/1.png)
---

## 📁 Project Structure
```

~/.config/nvim

├── init.lua                  # Entry point
├── lazy-lock.json            # Plugin lockfile (Lazy.nvim)
├── ftplugin/markdown.lua     # Filetype-specific settings
├── lua/
│   ├── core/                 # Editor options and keymaps
│   │   ├── options.lua
│   │   └── keymaps.lua
│   ├── plugins/              # Plugin configurations
│   ├── custom/               # Personal tweaks (e.g., UI colors)
│   └── archive/              # Old/experimental configs
````
---

## ✨ Key Features

- 🔥 **Fast startup** thanks to Lazy.nvim
- 🧠 Powerful **LSP** setup with `nvim-lspconfig`
- 🌳 Syntax highlighting via `nvim-treesitter`
- 🔍 Fuzzy file search with `telescope.nvim`![фото](media/2.png)
- 🧭 Efficient navigation with `harpoon` and `hop.nvim`![фото](media/3.png)
- 🎯 Debugging support via `nvim-dap` and `dap-ui`
- 🧱 Intuitive code completion using `nvim-cmp`
- 🎨 Custom UI with `lualine`, `barbecue.nvim`, and smooth colors
- 🧼 Code formatting and linting helpers
- 💡 Git integration via `gitsigns.nvim` and `git-blame.nvim`
- 🎨 Custom random tabs colors![фото](media/4.gif)

---

## 🚀 Getting Started

### Prerequisites

Tested on Ubuntu / Debian with GNOME. The dark/light theme detector reads `gsettings org.gnome.desktop.interface color-scheme`; on other DEs it falls back to dark.

**Required:**

| Tool | Why | Ubuntu/Debian install |
|---|---|---|
| Neovim ≥ 0.9 | The editor | `sudo apt install neovim` (or build from source for latest) |
| `git` | Lazy.nvim clones plugins | `sudo apt install git` |
| `make` + C compiler | Builds `telescope-fzf-native` and treesitter parsers | `sudo apt install build-essential` |
| `ripgrep` | Telescope live grep (`<leader>fg`) | `sudo apt install ripgrep` |
| Nerd Font | Icons in lualine / barbar / neo-tree | e.g. [JetBrainsMono Nerd Font](https://www.nerdfonts.com/) — set in your terminal |
| Clipboard tool | `"+y` / `"+p` system-clipboard yank/paste | X11: `sudo apt install xclip`; Wayland: `sudo apt install wl-clipboard` |

**Recommended (specific features will warn if missing):**

| Tool | Feature |
|---|---|
| `lazygit` | `<leader>lg` git TUI — see install snippet below (official GitHub release; the `lazygit-team/release` PPA does not publish for Ubuntu 24.04 noble) |
| `fd-find` | Faster Telescope `find_files` (binary is `fdfind` on Debian) — `sudo apt install fd-find` |
| `xdg-utils` | `gx` opens URL under cursor via `xdg-open` — usually preinstalled |

**Auto-installed by the config (no manual action needed):**

- LSP servers via Mason: `lua_ls`, `lemminx`, `marksman`, `quick_lint_js`, `pyright`
- Treesitter parsers: `lua`, `python`
- All Lua plugins via `lazy.nvim` on first launch

### One-liner for fresh Ubuntu

```bash
sudo apt update && sudo apt install -y \
  neovim git build-essential ripgrep \
  fd-find xclip
```

(swap `xclip` for `wl-clipboard` on Wayland.)

Then install **lazygit** from its GitHub release (the apt PPA is not available on Ubuntu 24.04):

```bash
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit -D -t /usr/local/bin/
rm /tmp/lazygit /tmp/lazygit.tar.gz
```

### Installation

```bash
git clone https://github.com/anticrab/anticrab.nvim ~/.config/nvim
nvim
```

Lazy.nvim will automatically bootstrap and install plugins on first run. After that, run `:Lazy sync` once to be sure everything is up to date, and `:Mason` to verify LSP servers installed cleanly.

---

## **🧩 Highlighted Plugins**

|**Plugin**|**Purpose**|
|---|---|
|telescope.nvim|Fuzzy finding (files, buffers, grep)|
|nvim-treesitter|Better syntax highlighting|
|nvim-cmp|Completion engine|
|nvim-lspconfig|Language Server Protocol|
|nvim-dap + dap-ui|Debugger support|
|gitsigns.nvim|Git gutter and inline blame|
|harpoon|Quick file/project jumping|
|lualine.nvim|Statusline|
|barbar.nvim|Tabline/bufferline|
|hop.nvim|Easy cursor motion|

---

## **⚙️ Customization**

Edit any file under lua/core or lua/plugins to adjust settings and plugin behaviors.
