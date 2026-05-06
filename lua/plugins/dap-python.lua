-- Python debugger wrapper around nvim-dap. Uses debugpy installed by Mason.
return {
  "mfussenegger/nvim-dap-python",
  dependencies = { "mfussenegger/nvim-dap" },
  ft = "python",
  config = function()
    local debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
    require("dap-python").setup(debugpy_python)

    local map = vim.keymap.set
    map("n", "<leader>dpt", function() require("dap-python").test_method() end, { desc = "DAP: Python test method" })
    map("n", "<leader>dpc", function() require("dap-python").test_class() end,  { desc = "DAP: Python test class" })
    map("v", "<leader>dps", function() require("dap-python").debug_selection() end, { desc = "DAP: Python debug selection" })
  end,
}
