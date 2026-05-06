-- conform.nvim — format-on-save with optional Docker-routed C/C++ formatter.
-- When a project's `.nvim-docker.lua` marker sets `formatters.cpp = "clang_format_container"`,
-- clang-format runs inside the container so it picks up the project's .clang-format
-- and any in-container clang-format version pinning.
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  config = function()
    local docker_project = require("core.docker-project")
    local docker_exec = require("core.docker-project.exec")
    local cfg = docker_project.config()

    local formatters_by_ft = {
      python = { "ruff_format", "ruff_organize_imports" },
      cpp = { "clang_format" },
      c = { "clang_format" },
    }

    local custom_formatters = {}

    if cfg then
      -- Custom formatter that pipes the buffer through `clang-format` running
      -- inside the container. Filename is translated host→container so the
      -- container clang-format can locate the project's .clang-format.
      custom_formatters.clang_format_container = {
        command = "docker",
        stdin = true,
        args = function(_, ctx)
          local fname = ctx.filename or ""
          local container_path = fname
          for _, pm in ipairs(cfg.path_mappings or {}) do
            if vim.startswith(fname, pm.host) then
              container_path = pm.container .. fname:sub(#pm.host + 1)
              break
            end
          end
          local inner_argv = { "clang-format", "--assume-filename=" .. container_path }
          local full = docker_exec.build(cfg, inner_argv)
          -- conform supplies `command` ("docker") as argv[0], so strip it.
          return vim.list_slice(full, 2)
        end,
      }

      local f = cfg.formatters or {}
      if f.cpp == "clang_format_container" then
        formatters_by_ft.cpp = { "clang_format_container" }
        formatters_by_ft.c = { "clang_format_container" }
      end
    end

    require("conform").setup({
      formatters_by_ft = formatters_by_ft,
      formatters = custom_formatters,
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "never",
      },
    })
  end,
}
