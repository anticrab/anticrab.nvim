return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      -- Авто-открытие UI при старте дебага и закрытие при завершении
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymaps (общие, язык-агностичные)
      local map = vim.keymap.set
      map("n", "<leader>dc",  function() dap.continue() end, { desc = "DAP continue" })
      map("n", "<leader>dso", function() dap.step_over() end, { desc = "DAP step over" })
      map("n", "<leader>dsi", function() dap.step_into() end, { desc = "DAP step into" })
      map("n", "<leader>dsout", function() dap.step_out() end, { desc = "DAP step out" })
      map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP toggle breakpoint" })
      map("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP conditional breakpoint" })
      map("n", "<leader>dr", function() dap.repl.open() end, { desc = "DAP REPL" })
      map("n", "<leader>du", function() dapui.toggle() end, { desc = "DAP UI toggle" })
    end,
  },
}
