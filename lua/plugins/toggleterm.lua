-- toggleterm.nvim — kept ONLY as a dependency of the docker-project "tail logs"
-- feature (`<leader>Dl`, see lua/core/docker-project/keymaps.lua), which opens
-- `docker compose logs --follow` in a toggleterm Terminal tab.
--
-- The interactive scratch terminals (floating `<leader>/` + numbered
-- `<leader>t1`–`<leader>t9`) were removed — run shells in tmux instead.
--
-- lazy = true: the plugin loads on demand the first time the docker code
-- `require("toggleterm.terminal")`s it; `opts` makes lazy run setup on load.
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  lazy = true,
  opts = {
    direction = "float",
    float_opts = {
      border = "rounded",
      winblend = 0,
    },
    shade_terminals = false,
    start_in_insert = true,
    persist_size = false,
    persist_mode = true,
  },
}
