# 🛠️ My Neovim Config

A modern, modular Neovim configuration written in **Lua**, focused on performance, convenience, and an enjoyable coding experience.

> ⚡ Powered by [Lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager.

![screenshot](media/1.png)
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
- 🧠 Powerful **LSP** setup with `nvim-lspconfig` + Mason auto-install
- 🌳 Syntax highlighting via `nvim-treesitter`
- 🔍 Fuzzy file search with `telescope.nvim` ![screenshot](media/2.png)
- 🧭 Lightning-fast navigation with `flash.nvim` ![screenshot](media/3.png)
- 🎯 Debugging via `nvim-dap` + `dap-ui` (Python via debugpy, C/C++ via codelldb)
- 🧱 Code completion through `nvim-cmp` + LuaSnip
- 🎨 Custom UI: `lualine`, `barbar`, `barbecue` breadcrumbs, `catppuccin` theme (auto-syncs to GNOME light/dark)
- 🧼 Format-on-save via `conform.nvim` (Python `ruff`, C/C++ `clang-format`)
- 💡 Git: `gitsigns.nvim` (hunk gutter), `diffview.nvim` (PR-style diffs), `lazygit` integration
- 🖥 Built-in terminal layer via `toggleterm.nvim`: floating quick-shell + numbered buffer-terminals
- ⌨️ Live keybinding hints with `which-key.nvim`
- 🎨 Custom random tabs colors ![screenshot](media/4.gif)

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
  neovim git curl build-essential \
  ripgrep fd-find xclip
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

### After first launch — install Mason-managed tools

The config uses [mason-tool-installer](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) to auto-install non-LSP tools (`ruff`, `clang-format`, `debugpy`, `codelldb`) on first start. To verify or trigger manually:

```vim
:Mason                 " UI: see what's installed
:MasonToolsInstall     " kick off the auto-install (async)
```

LSP servers are auto-installed via `mason-lspconfig` (`lua_ls`, `lemminx`, `marksman`, `quick_lint_js`, `pyright`, `clangd`).

Wait until installs complete (Mason shows progress in top-right). After that, run:

```vim
:checkhealth
```

to confirm everything is green. The config explicitly disables Node / Perl / Ruby / Python-host providers, so warnings about missing `neovim` npm package, `Neovim::Ext`, `ruby/gem`, or `pynvim` are silenced.

### Installation

```bash
git clone https://github.com/anticrab/anticrab.nvim ~/.config/nvim
nvim
```

Lazy.nvim will automatically bootstrap and install plugins on first run. After that, run `:Lazy sync` once to be sure everything is up to date, and `:Mason` to verify LSP servers installed cleanly.

### First-launch checklist

If this is your first time:

1. **Set a Nerd Font in your terminal.** Without it, status-line and file-tree icons render as boxes. Examples: JetBrainsMono Nerd Font, FiraCode Nerd Font.
2. **Clone and launch** (commands above). Lazy.nvim auto-bootstraps; on the first launch you'll see a progress bar while plugins clone — wait it out (~1 min).
3. **Inside nvim, run `:Mason`** to confirm LSP servers are installed (`pyright`, `clangd`, `lua_ls`, etc.). They auto-install via `mason-lspconfig`; if any are missing, run `:MasonToolsInstall` and wait.
4. **Run `:checkhealth`** — should be all green except the providers section (those are intentionally disabled).
5. **You're done.** No manual config edits are required to start. Open a file in your project and edit normally.

> 🐳 **About `.nvim-docker.lua`:** ignore it unless your project's toolchain lives in a Docker container. For native C++ / Python / Go / web projects on the host, do nothing — host LSPs work as in any standard nvim setup. The Docker section below is opt-in and only relevant if you want to route LSP / linters / formatters into a container.

### Common keybindings

A small starter set; full reference in [`CHEATSHEET.md`](./CHEATSHEET.md). Press `<leader>?` (Space + `?`) inside nvim for the live picker.

| Key | Action |
|---|---|
| `<leader>ff` | Fuzzy find files (Telescope) |
| `<leader>fg` | Live grep across project |
| `<leader><leader>` | Reveal current file in file explorer |
| `ss` / `S` | Flash 2-char jump / treesitter-aware jump |
| `<leader>lg` | Open lazygit |
| `<leader>/` | Toggle floating terminal |
| `<leader>t1`–`<leader>t9` | Numbered terminal buffers |
| `<leader>ww` / `<leader>qq` | Save / quit |

### Troubleshooting

**LSP not starting / "no LSP attached" on a file?**
- `:Mason` — confirm the relevant server (e.g. `pyright`, `clangd`) is installed.
- `:LspInfo` — shows attached clients on the current buffer.
- `:MasonToolsInstall` — re-runs the formatter / debugger installs (`ruff`, `clang-format`, `debugpy`, `codelldb`).

**No icons / boxes everywhere in lualine / file tree?**
- Set your terminal font to a Nerd Font. The plugins use `nvim-web-devicons` glyphs.

**Clipboard `"+y` / `"+p` doesn't reach the system clipboard?**
- X11: `sudo apt install xclip`. Wayland: `sudo apt install wl-clipboard`.
- Verify via `:echo has('clipboard')` (must print `1`).

**Treesitter highlighting broken for some language?**
- `:TSInstall <lang>` — installs the parser. Default `ensure_installed`: `lua`, `python`, `c`, `cpp`, `cmake`. Other filetypes auto-install on first open.

**Sessions not restoring?**
- auto-session writes to `~/.local/share/nvim/sessions/`. Check it exists; use `:SessionRestore` if the auto-restore didn't kick in.

**Docker-based project: LSP stuck after a rebuild inside the container?**
- `<leader>Dr` — restarts wrapped LSPs. The inotify across bind-mounts is unreliable on Linux, so this is the canonical "I just rebuilt" hotkey.

---

## 🐳 Docker-based projects (per-project LSP / linters / formatters)

> ⚠️ **Skip this section unless your project's toolchain lives in a Docker container** (e.g., ROS2 in `osrf/ros:humble-desktop`, embedded toolchains, Yocto SDK). For native projects you don't need any of it.

For projects whose toolchain lives inside a Docker container, drop a `.nvim-docker.lua` marker at the project root. nvim will route configured LSPs, linters, and formatters through `docker exec` so they pick up the container's headers / language deps / linter configs. Project commands (`<leader>D<key>`) are dispatched to a single persistent in-container shell, with full output history visible in its own tab.

**How it works:**
- Marker present + container running → wrapped LSP runs inside the container, with `clangd --path-mappings` translating between host paths (what nvim sees) and container paths (where the headers live).
- Marker present + container down → no LSP starts, single notify suggesting `<leader>Ds` and `:LspRestart`. No host-fallback — host LSP would just spam errors with no ROS2 / std headers visible.
- No marker → host LSP behaves exactly as for any non-container project.

**Marker schema (every field except `schema_version` and `exec` is optional):**

```lua
return {
  schema_version = 1,

  -- Container coordinates. `kind = "compose"` invokes `docker compose`;
  -- `kind = "container"` uses raw `docker exec` with `name = "..."`.
  exec = {
    kind         = "compose",
    project_name = "<compose project name>",
    env_file     = ".env",                    -- optional
    file         = "docker/docker-compose.yaml",
    service      = "development",
    user         = "current",                 -- "current" → $(id -u):$(id -g)
  },

  -- Sourced before every wrapped command (LSP / linter / formatter / project commands).
  setup_cmd = "source ./activate.sh",

  -- Translate host paths to in-container paths at the LSP boundary.
  -- Required for clangd's --path-mappings to resolve files correctly.
  path_mappings = {
    { host = "/abs/host/path", container = "/abs/container/path" },
  },

  -- In-container working directory. Every `commands[*].cmd` is prepended with
  -- `cd <workspace.dir> && ` so commands stay short. Also serves as clangd's
  -- default `--compile-commands-dir`.
  workspace = { dir = "/abs/container/workspace/path" },

  -- Wrap these language servers
  lsp = {
    clangd  = { enabled = true,
                compile_commands_dir = nil },  -- override; defaults to workspace.dir
    pyright = { enabled = true },
  },

  -- Run these linters via nvim-lint on save
  linters = {
    python = { "ament_flake8", "ament_pep257" },  -- or { "flake8" }, etc.
    cpp    = { "clangtidy" },
  },

  formatters = {
    cpp = "clang_format_container",  -- runs clang-format in the container
  },

  -- Project-defined commands. Each entry becomes <leader>D<key>.
  -- Reserved keys (built-in): s = shell, r = restart LSPs, i = info, l = logs.
  commands = {
    -- Direct command (no prompt)
    {
      key  = "b",
      desc = "Build",
      cmd  = "make",
    },

    -- Command that prompts the user via vim.ui.select. `select_from` is run
    -- inside the container; each line of its output becomes one option. The
    -- chosen value replaces `{pkg}` in `cmd`.
    {
      key         = "B",
      desc        = "Build one target",
      select_from = "make -qp | awk -F: '/^[a-zA-Z0-9_-]+:/ {print $1}' | sort -u",
      cmd         = "make {pkg}",
    },
  },
}
```

**Worked example — a ROS2 colcon workspace:**

```lua
return {
  schema_version = 1,
  exec = {
    kind = "compose",
    project_name = "myproj",
    env_file = ".env",
    file = "docker/deployment/docker-compose.yaml",
    service = "development",
    user = "current",
  },
  setup_cmd = "source /opt/ros/humble/setup.bash && "
           .. "([ -f ~/dev_ws/install/setup.bash ] && source ~/dev_ws/install/setup.bash || true)",
  path_mappings = {
    { host = "/home/<you>/projects/myproj/src",
      container = "/home/<you>/dev_ws/src" },
  },
  workspace = { dir = "/home/<you>/dev_ws" },
  lsp = { clangd = { enabled = true }, pyright = { enabled = true } },
  linters = {
    python = { "ament_flake8", "ament_pep257" },
    cpp    = { "clangtidy" },
  },
  formatters = { cpp = "clang_format_container" },

  commands = {
    { key = "b", desc = "Build workspace",
      cmd = "colcon build --symlink-install && "
         .. "find build -mindepth 2 -maxdepth 2 -name compile_commands.json "
         .. "-exec cat {} + | jq -s 'add' > compile_commands.json" },
    { key = "B", desc = "Build one package",
      select_from = "colcon list -n",
      cmd = "colcon build --symlink-install --packages-select {pkg} && "
         .. "find build -mindepth 2 -maxdepth 2 -name compile_commands.json "
         .. "-exec cat {} + | jq -s 'add' > compile_commands.json" },
    { key = "t", desc = "Test all",
      cmd = "colcon test && colcon test-result --verbose" },
    { key = "T", desc = "Test one package",
      select_from = "colcon list -n",
      cmd = "colcon test --packages-select {pkg} && colcon test-result --verbose" },
  },
}
```

**Plain CMake project — no ROS2:**

```lua
return {
  schema_version = 1,
  exec = { kind = "container", name = "myproj-build", user = "current" },
  path_mappings = {
    { host = "/home/<you>/projects/myproj", container = "/work" },
  },
  workspace = { dir = "/work" },
  lsp = { clangd = { enabled = true } },
  formatters = { cpp = "clang_format_container" },
  commands = {
    { key = "b", desc = "Build",        cmd = "cmake --build build" },
    { key = "c", desc = "Configure",    cmd = "cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
    { key = "t", desc = "Run tests",    cmd = "ctest --test-dir build --output-on-failure" },
  },
}
```

**First-run trust prompt:** nvim uses `vim.secure.read`, so the first time you open the project (or after any change to the marker) you'll be asked to trust the file. Choose `view` to inspect, then run `:trust` while the marker buffer is current. The decision is remembered in `~/.local/state/nvim/trust`.

> ⚠️ Make sure the marker file (`.nvim-docker.lua`) is the **current buffer** when you run `:trust` — `:trust` operates on the current buffer. Trusting a different file silently does the wrong thing.

**Tools the container must provide.** The wrapped LSPs / linters / formatters all run inside your container, so its image needs to ship them. For a fresh container, add the following to your Dockerfile (paths inside the container):

```dockerfile
# C/C++: clangd language server (the package ships clangd-N; alias to `clangd`)
RUN apt-get update && apt-get install -y --no-install-recommends \
        clangd-15 jq \
    && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-15 100 \
    && rm -rf /var/lib/apt/lists/*

# Python: pyright LSP (npm-distributed; pip wrapper bundles node)
RUN pip3 install --no-cache-dir pyright
```

`jq` is required by `<leader>Db` to merge per-package `compile_commands.json` into one workspace DB. `clangd-15` is what was tested; any modern clangd works — pin a version that matches your toolchain.

For ROS2-specific tooling (`ament_flake8`, `ament_pep257`, `clang-format`, `clang-tidy`) use the ROS apt packages, e.g. `ros-humble-ament-flake8`, `ros-humble-ament-pep257`, plus distribution `clang-format`/`clang-tidy`.

**One persistent shell, one tab:** Every project-defined `<leader>D<key>` command — and `<leader>Ds` — is dispatched to a **singleton in-container bash** that lives in its own nvim tab. Output history accumulates across all runs, so you can scroll back. The first command opens the tab; later commands focus it (or open it again if you closed it). The shell is fully interactive — you can type your own commands too.

**Built-in keybindings (always registered):**

| Key | Action |
|---|---|
| `<leader>Ds` | Focus / open the persistent shell tab |
| `<leader>Dr` | Restart wrapped LSPs (run after any rebuild — see inotify caveat) |
| `<leader>Di` | Print marker info (root, mappings, container status, wrapped servers, project commands, shell state) |
| `<leader>Dl` | Tail container logs (separate tab — runs `docker compose logs --follow` outside the container) |

Inside the shell tab, press `q` in normal-mode to close the tab (the shell keeps running; reopen via `<leader>Ds`).

Reserved keys: `s`, `r`, `i`, `l` cannot be used in `commands[*].key`.

**Project-defined keybindings:** every entry of `commands` becomes `<leader>D<key>`. They are visible in `<leader>Di`'s output and in the which-key popup.

**Diagnose with `:checkhealth core.docker-project`:** reports marker presence, container status, in-container `clangd` reachability, compile_commands status, latency probe, and path-mapping sanity.

**Caveats (must know):**
- **Path mappings are absolute.** The marker's host paths are realpath-resolved at load time — symlinks in `~/projects/...` are warned about.
- **Jump-to-def into `/opt/ros/humble`** points to a container-only path. nvim will fail to open it; the limitation is documented and accepted.
- **inotify across bind-mounts is unreliable on Linux.** A rebuild inside the container won't auto-trigger clangd reindex. Use `<leader>Dr` after `<leader>Db`.
- **Per-package compile_commands.** Aggregation step (run by `<leader>Db`) merges all `build/*/compile_commands.json` into `~/dev_ws/compile_commands.json` inside the container so clangd finds one DB for the whole workspace.
- **First exec is slower** (~200–500 ms compose-resolve overhead). Subsequent stdio traffic is fast.

---

## **🧩 Plugins in this config**

**Core editing & UX**

| Plugin | Purpose |
|---|---|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager (auto-bootstraps) |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Live key hint popup after `<leader>` |
| [flash.nvim](https://github.com/folke/flash.nvim) | 2-char jump navigation (`ss` / `S`) |
| [mini.surround](https://github.com/echasnovski/mini.surround) | Add/change/delete surrounding pairs |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close brackets/quotes |
| [auto-save.nvim](https://github.com/okuuva/auto-save.nvim) | Save on InsertLeave / FocusLost |
| [auto-session](https://github.com/rmagatti/auto-session) | Save/restore sessions per cwd |
| [bigfile.nvim](https://github.com/LunarVim/bigfile.nvim) | Disable heavy features for files >2 MiB |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | `<C-h/j/k/l>` navigation across nvim & tmux |

**Find / files / structure**

| Plugin | Purpose |
|---|---|
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder (files, grep, LSP, etc.) |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer (floating popup; `<leader><leader>` reveals current file). The plugin spec lives in `lua/plugins/nvim-tree.lua` for historical reasons but configures neo-tree, not the legacy `nvim-tree`. |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting + parsers (lua, python, c, cpp, cmake) |
| [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo) | Smart code folding |

**LSP / completion / formatting / debug**

| Plugin | Purpose |
|---|---|
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) + [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP setup; auto-installs `lua_ls`, `marksman`, `lemminx`, `quick_lint_js`, `pyright`, `clangd` |
| [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Auto-installs `ruff`, `clang-format`, `debugpy`, `codelldb` |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) + [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Completion + snippets |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Format-on-save (Python `ruff`, C/C++ `clang-format`; container-routed when a `.nvim-docker.lua` marker is active) |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Async linters on save (only attaches per-marker — `ament_flake8` / `ament_pep257` / `clang-tidy` inside the container) |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) + [dap-ui](https://github.com/rcarriga/nvim-dap-ui) + [dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Debug Adapter Protocol with UI |
| [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) | Python debugger wrapper (via debugpy) |
| [trouble.nvim](https://github.com/folke/trouble.nvim) | Diagnostics/quickfix UI |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | TODO/FIXME/HACK highlighting + search |

**Git & terminal**

| Plugin | Purpose |
|---|---|
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git gutter + hunk operations + blame |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | PR-style diff & file history |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Floating / numbered terminals + lazygit launcher |

**Look & feel**

| Plugin | Purpose |
|---|---|
| [catppuccin/nvim](https://github.com/catppuccin/nvim) | Theme (auto-syncs to GNOME color-scheme) |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [barbar.nvim](https://github.com/romgrk/barbar.nvim) | Buffer tabs at top |
| [barbecue.nvim](https://github.com/utilyre/barbecue.nvim) | LSP breadcrumbs in winbar |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Indent guides |

---

## **⚙️ Customization**

Edit any file under lua/core or lua/plugins to adjust settings and plugin behaviors.
