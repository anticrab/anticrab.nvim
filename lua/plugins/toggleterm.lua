-- Floating terminal + lazygit (toggleterm) + numbered buffer-terminals (нативные :terminal буферы)
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  cmd = { "ToggleTerm", "TermExec" },
  opts = {
    direction = "float",
    size = function(term)
      if term.direction == "horizontal" then
        return math.floor(vim.o.lines * 0.3)
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
    float_opts = {
      border = "rounded",
      winblend = 0,
    },
    shade_terminals = false,
    start_in_insert = true,
    persist_size = false,
    persist_mode = true,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal

    -- Quick float — для коротких ad-hoc команд
    local float_term = Terminal:new({
      direction = "float",
      float_opts = { border = "rounded" },
      hidden = true,
    })

    -- Lazygit на весь экран
    local lazygit = Terminal:new({
      cmd = "lazygit",
      direction = "float",
      float_opts = {
        border = "rounded",
        width = function() return math.floor(vim.o.columns * 0.95) end,
        height = function() return math.floor(vim.o.lines * 0.92) end,
      },
      hidden = true,
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      end,
    })

    local map = vim.keymap.set
    map("n", "<leader>/",  function() float_term:toggle() end, { desc = "Terminal float (quick)" })
    map("n", "<leader>lg", function()
      if vim.fn.executable("lazygit") == 0 then
        vim.notify("lazygit not installed. Run: sudo apt install lazygit", vim.log.levels.ERROR)
        return
      end
      lazygit:toggle()
    end, { desc = "Lazygit (float)" })

    -- Numbered terminal-buffers — обычные :terminal буферы, видны в barbar сверху как вкладки.
    -- Создаются на первом нажатии, переиспользуются на последующих.
    local term_buffers = {}
    for i = 1, 9 do
      map("n", "<leader>t" .. i, function()
        local buf = term_buffers[i]
        if buf and vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_set_current_buf(buf)
        else
          vim.cmd("enew")
          vim.cmd("terminal")
          buf = vim.api.nvim_get_current_buf()
          term_buffers[i] = buf
          pcall(vim.cmd, "file term-" .. i)
          vim.bo[buf].buflisted = true
        end
        vim.cmd("startinsert")
      end, { desc = "Terminal #" .. i })
    end

    -- Удобный выход из terminal-mode: jk → normal-mode
    -- Esc не трогаем, чтобы TUI-приложения (lazygit, htop) могли его использовать.
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = function()
        local kopts = { buffer = 0, silent = true }
        vim.keymap.set("t", "jk", [[<C-\><C-n>]], kopts)
        vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], kopts)
        vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], kopts)
        vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], kopts)
        vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], kopts)
      end,
    })
  end,
}
