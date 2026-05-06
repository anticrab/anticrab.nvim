-- Auto-install non-LSP tools (formatters, linters, debug adapters) via Mason
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "williamboman/mason.nvim" },
  event = "VeryLazy",
  cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate", "MasonToolsClean" },
  config = function()
    require("mason-tool-installer").setup({
      ensure_installed = {
        "ruff",         -- Python: formatter + linter
        "clang-format", -- C/C++: formatter
        "debugpy",      -- Python: DAP
        "codelldb",     -- C/C++: DAP
      },
      auto_update = false,
      run_on_start = true,
    })
  end,
}
