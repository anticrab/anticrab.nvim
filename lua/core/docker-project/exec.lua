-- Build `docker (compose) exec` invocations for a marker config.
--
-- The output is always a Lua array of strings suitable for passing to
-- vim.lsp.start_client / vim.system / Job:new. The shell command that runs
-- *inside* the container is wrapped in `bash -c "<setup_cmd> && exec <inner>"`
-- so the ROS2 environment is sourced before the LSP / linter / formatter
-- starts.

local M = {}

-- Resolve `user = "current"` to "$(id -u):$(id -g)" at call time.
local function resolve_user(user)
  if not user or user == "" then return nil end
  if user == "current" then
    local pw = vim.uv.os_get_passwd()
    return ("%d:%d"):format(pw.uid, pw.gid)
  end
  return user
end

-- Quote a string for use inside a single-quoted bash -c argument.
-- We're going to wrap the inner command in single quotes, so any single quote
-- inside it has to be closed, escaped, and reopened.
local function shell_squote(s)
  return "'" .. s:gsub("'", [['\'']]) .. "'"
end

-- Build the array of strings that runs `inner_cmd` inside the project's
-- container. `inner_cmd` is the *bash* command that should run after the
-- marker's setup_cmd. It can be a single string (shell-interpreted) or an
-- array of strings (joined with spaces — caller must pre-escape).
-- opts.interactive = true allocates a TTY (for shell use); default is
-- non-interactive (LSPs / formatters / linters).
function M.build(cfg, inner_cmd, opts)
  assert(cfg and cfg.exec, "docker-project.exec.build: missing cfg.exec")
  opts = opts or {}

  if type(inner_cmd) == "table" then
    -- Caller-provided argv: shell-quote each piece.
    local pieces = {}
    for _, p in ipairs(inner_cmd) do
      pieces[#pieces + 1] = shell_squote(p)
    end
    inner_cmd = table.concat(pieces, " ")
  end

  local setup = cfg.setup_cmd or ""
  -- For single-command inner (e.g. `clangd ...`) we'd ideally `exec` to skip
  -- the bash layer, but that breaks multi-statement payloads (`a && b; c`).
  -- Plain concatenation is portable and the bash-parent overhead is negligible.
  local payload = (setup ~= "" and (setup .. " && ") or "") .. inner_cmd

  local exec = cfg.exec
  local user = resolve_user(exec.user)
  local cmd = {}

  -- Resolve a path declared in the marker against the project root, so the
  -- caller's cwd doesn't matter (LSP spawns from buffer dir, etc.).
  local function abs(p)
    if not p or p == "" or vim.startswith(p, "/") then return p end
    return (cfg._root or vim.fn.getcwd()) .. "/" .. p
  end

  if exec.kind == "compose" then
    table.insert(cmd, "docker")
    table.insert(cmd, "compose")
    if exec.project_name and exec.project_name ~= "" then
      table.insert(cmd, "--project-name")
      table.insert(cmd, exec.project_name)
    end
    if exec.env_file and exec.env_file ~= "" then
      table.insert(cmd, "--env-file")
      table.insert(cmd, abs(exec.env_file))
    end
    table.insert(cmd, "-f")
    table.insert(cmd, abs(exec.file))
    table.insert(cmd, "exec")
    if not opts.interactive then
      table.insert(cmd, "-T")
    end
    if user then
      table.insert(cmd, "--user")
      table.insert(cmd, user)
    end
    table.insert(cmd, exec.service)
  else -- "container"
    table.insert(cmd, "docker")
    table.insert(cmd, "exec")
    table.insert(cmd, opts.interactive and "-it" or "-i")
    if user then
      table.insert(cmd, "--user")
      table.insert(cmd, user)
    end
    table.insert(cmd, exec.name)
  end

  table.insert(cmd, "bash")
  table.insert(cmd, "-c")
  table.insert(cmd, payload)
  return cmd
end

-- Run a command synchronously inside the container, return (rc, stdout, stderr).
-- `cwd` defaults to the project root (the dir that contains the marker), so
-- compose-relative paths in the marker (e.g. `docker/.../docker-compose.yaml`)
-- resolve correctly.
function M.run(cfg, inner_cmd, opts)
  opts = opts or {}
  local argv = M.build(cfg, inner_cmd)
  local res = vim.system(argv, {
    cwd = opts.cwd or cfg._root,
    text = true,
    timeout = opts.timeout or 10000,
  }):wait()
  return res.code, res.stdout or "", res.stderr or ""
end

return M
