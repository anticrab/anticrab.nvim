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

- Neovim ≥ 0.9.0
- Git
- Nerd Font (e.g. [JetBrainsMono Nerd Font](https://www.nerdfonts.com/))

### Installation

```bash
git clone https://github.com/anticrab/anticrab.nvim ~/.config/nvim
nvim
```

Lazy.nvim will automatically bootstrap and install plugins on first run.

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
