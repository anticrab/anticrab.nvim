-- Async linters via mfussenegger/nvim-lint.
--
-- For Docker-rooted projects (marker active), linters are wrapped to run
-- inside the container so they see ROS2 deps and use ament's tooling. Without
-- a marker, this plugin still loads but registers no linters by default —
-- pyright/clangd handle diagnostics on their own.
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    local docker_project = require("core.docker-project")
    local docker_exec = require("core.docker-project.exec")
    local cfg = docker_project.config()

    -- Translate a host path to a container path (or return host path unchanged).
    local function host_to_container(host_path)
      if not cfg or not host_path or host_path == "" then return host_path end
      for _, pm in ipairs(cfg.path_mappings or {}) do
        if vim.startswith(host_path, pm.host) then
          return pm.container .. host_path:sub(#pm.host + 1)
        end
      end
      return host_path
    end

    -- Helper: turn a "native" linter spec into one that runs inside the
    -- container. Strategy: cmd = "docker"; args = the `docker … exec … bash -c`
    -- argv with argv[0] ("docker") stripped.
    --
    -- nvim-lint requires `args` to be a LIST whose elements are strings or
    -- `fun():string` (it does `vim.tbl_map(eval, args)`), NOT a single function.
    -- The docker prefix is static for a given cfg; only the final `bash -c`
    -- payload depends on the current buffer, so just that last element is a
    -- function. We also set `append_fname = false` so nvim-lint doesn't tack the
    -- buffer's *host* path onto the end of the docker invocation.
    local function wrap_linter(name, inner_bin, native_args)
      -- Resolve the in-container `bash -c` payload for the current buffer.
      local function payload()
        local container_path = host_to_container(vim.api.nvim_buf_get_name(0))
        local inner = { inner_bin }
        for _, a in ipairs(native_args) do
          if a == "{file}" or a == "$FILENAME" then
            table.insert(inner, container_path)
          else
            table.insert(inner, a)
          end
        end
        local full = docker_exec.build(cfg, inner)
        return full[#full] -- the bash payload is the last argv element
      end

      -- Static argv prefix (everything except argv[0]="docker" and the payload).
      local sample = docker_exec.build(cfg, "x")
      local args = vim.list_slice(sample, 2, #sample - 1)
      table.insert(args, payload)

      local linter = lint.linters[name] or {}
      linter.cmd = "docker"
      linter.stdin = false
      linter.append_fname = false
      linter.ignore_exitcode = true
      linter.args = args
      lint.linters[name] = linter
    end

    if cfg then
      -- Python: ament_flake8 + ament_pep257. Output formats are flake8 /
      -- pydocstyle compatible, so nvim-lint's stock parsers work.
      local linters = cfg.linters or {}
      local py_linters = linters.python or {}
      local cpp_linters = linters.cpp or {}
      local linters_by_ft = {}

      for _, name in ipairs(py_linters) do
        if name == "ament_flake8" then
          -- ament_flake8 wraps flake8 but exposes NEITHER `--format` nor
          -- `--no-show-source` (the latter makes it exit 2 with a usage error),
          -- so we can't coerce flake8's colon-delimited format that nvim-lint's
          -- stock parser expects. Parse ament_flake8's native output instead:
          --   <path>:<line>:<col>: <CODE> <message>
          -- The anchored pattern only matches those lines; the source-echo
          -- header and the trailing summary footer are ignored.
          lint.linters.ament_flake8 = {
            parser = require("lint.parser").from_pattern(
              "^[^:]+:(%d+):(%d+): (%w+) (.+)",
              { "lnum", "col", "code", "message" },
              nil,
              { ["source"] = "ament_flake8", ["severity"] = vim.diagnostic.severity.WARN }
            ),
          }
          wrap_linter("ament_flake8", "ament_flake8", { "{file}" })
          linters_by_ft.python = linters_by_ft.python or {}
          table.insert(linters_by_ft.python, "ament_flake8")
        elseif name == "ament_pep257" then
          lint.linters.ament_pep257 = vim.deepcopy(lint.linters.pydocstyle or {
            -- Fallback: minimal parser if pydocstyle isn't bundled in this
            -- nvim-lint version. Output: "<file>:<line> <code>: <msg>".
            parser = require("lint.parser").from_pattern(
              "([^:]+):(%d+) ([%a%d]+): (.+)",
              { "file", "lnum", "code", "message" },
              nil,
              { ["source"] = "pep257", ["severity"] = vim.diagnostic.severity.WARN }
            ),
          })
          wrap_linter("ament_pep257", "ament_pep257", { "{file}" })
          linters_by_ft.python = linters_by_ft.python or {}
          table.insert(linters_by_ft.python, "ament_pep257")
        end
      end

      for _, name in ipairs(cpp_linters) do
        if name == "clangtidy" then
          lint.linters.clangtidy_container = vim.deepcopy(lint.linters.clangtidy)
          wrap_linter("clangtidy_container", "clang-tidy", { "--quiet", "{file}" })
          linters_by_ft.cpp = { "clangtidy_container" }
          linters_by_ft.c   = { "clangtidy_container" }
        end
      end

      lint.linters_by_ft = vim.tbl_deep_extend("force", lint.linters_by_ft or {}, linters_by_ft)

      -- Trigger linting on save and when leaving insert mode.
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function() pcall(lint.try_lint) end,
      })
    end
  end,
}
