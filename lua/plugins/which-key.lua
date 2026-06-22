-- Live key-binding hints. Жмёшь <leader> и через 300мс видишь все доступные продолжения с описаниями.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    preset = "modern",
    delay = 300,
    icons = {
      mappings = false, -- без эмодзи в подсказках
    },
    spec = {
      { "<leader>c", group = "diff (Conflict)" },
      { "<leader>d", group = "Diffview / DAP" },
      { "<leader>D", group = "Docker project" },
      { "<leader>e", group = "Explorer / Errors" },
      { "<leader>f", group = "Find (Telescope)" },
      { "<leader>g", group = "LSP / Goto" },
      { "<leader>o", group = "Ollama / Avante" },
      { "<leader>q", group = "Quit / Quickfix" },
      { "<leader>r", group = "Rename" },
      { "<leader>s", group = "Splits" },
      { "<leader>t", group = "Tabs / Buffers" },
      { "<leader>T", group = "Tabs (move)" },
      { "<leader>w", group = "Write" },
      { "<leader>x", group = "Trouble" },
      { "<leader>y", group = "Yank path" },
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer keymaps (which-key)",
    },
  },
}
