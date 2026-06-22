-- conform.nvim — manual formatting (format-on-save OFF by default) with optional
-- Docker-routed C/C++ formatter.
--
-- Format-on-save is disabled by default. Управление:
--   :Format        — отформатировать текущий буфер вручную
--   :FormatEnable  — включить автоформат при сохранении
--   :FormatDisable — выключить обратно
--   :FormatToggle  — переключить
-- Состояние хранится в vim.g.autoformat (по умолчанию false).
-- When a project's `.nvim-docker.lua` marker sets `formatters.cpp = "clang_format_container"`,
-- clang-format runs inside the container so it picks up the project's .clang-format
-- and any in-container clang-format version pinning.
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = { "Format", "FormatEnable", "FormatDisable", "FormatToggle" },
  config = function()
    local docker_project = require("core.docker-project")
    local docker_exec = require("core.docker-project.exec")
    local cfg = docker_project.config()

    local formatters_by_ft = {
      python = { "ruff_format", "ruff_organize_imports" },
      cpp = { "clang_format" },
      c = { "clang_format" },
      markdown = { "prettier" },
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

    -- Format-on-save OFF by default. vim.g.autoformat включает его глобально,
    -- vim.b.autoformat — для конкретного буфера.
    if vim.g.autoformat == nil then
      vim.g.autoformat = false
    end

    require("conform").setup({
      formatters_by_ft = formatters_by_ft,
      formatters = custom_formatters,
      format_on_save = function(bufnr)
        local enabled = vim.b[bufnr].autoformat
        if enabled == nil then
          enabled = vim.g.autoformat
        end
        if not enabled then
          return
        end
        return { timeout_ms = 1000, lsp_format = "never" }
      end,
    })

    -- Ручное форматирование текущего буфера.
    vim.api.nvim_create_user_command("Format", function()
      require("conform").format({ async = true, lsp_format = "never", timeout_ms = 1000 })
    end, { desc = "Format buffer (conform)" })

    local function set_autoformat(state)
      vim.g.autoformat = state
      vim.notify("Format on save: " .. (state and "ON" or "OFF"), vim.log.levels.INFO)
    end

    vim.api.nvim_create_user_command("FormatEnable", function() set_autoformat(true) end,
      { desc = "Enable format-on-save" })
    vim.api.nvim_create_user_command("FormatDisable", function() set_autoformat(false) end,
      { desc = "Disable format-on-save" })
    vim.api.nvim_create_user_command("FormatToggle", function() set_autoformat(not vim.g.autoformat) end,
      { desc = "Toggle format-on-save" })
  end,
}
