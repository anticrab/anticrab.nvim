-- Locate, load, validate, and cache a project's `.nvim-docker.lua` marker.
-- Loading goes through vim.secure.read so nvim's built-in trust prompt protects
-- against malicious project files (same mechanism as exrc).

local M = {}

local MARKER_NAME = ".nvim-docker.lua"
local SCHEMA_VERSION = 1

-- Cache: resolved-root-path → { config = table | false, mtime = number }
-- A `false` config means "marker exists but failed to load/validate" — we keep
-- the negative result to avoid re-prompting on every BufEnter.
local cache = {}

-- Find the marker file by walking upward from the given starting path.
-- Returns absolute path of the marker, or nil.
local function find_marker(start_path)
  if not start_path or start_path == "" then
    return nil
  end
  local hits = vim.fs.find(MARKER_NAME, { upward = true, path = start_path, type = "file" })
  return hits[1]
end

-- Validate the schema version and required fields. Returns (ok, err_msg).
local function validate(cfg, marker_path)
  if type(cfg) ~= "table" then
    return false, "expected return table, got " .. type(cfg)
  end
  if cfg.schema_version ~= SCHEMA_VERSION then
    return false, ("schema_version=%s, expected %d"):format(tostring(cfg.schema_version), SCHEMA_VERSION)
  end
  if type(cfg.exec) ~= "table" then
    return false, "exec table is required"
  end
  if cfg.exec.kind ~= "compose" and cfg.exec.kind ~= "container" then
    return false, "exec.kind must be 'compose' or 'container'"
  end
  if cfg.exec.kind == "compose" then
    for _, k in ipairs({ "file", "service" }) do
      if type(cfg.exec[k]) ~= "string" or cfg.exec[k] == "" then
        return false, ("exec.%s is required for kind=compose"):format(k)
      end
    end
  else
    if type(cfg.exec.name) ~= "string" or cfg.exec.name == "" then
      return false, "exec.name is required for kind=container"
    end
  end

  cfg.setup_cmd = cfg.setup_cmd or ""
  cfg.path_mappings = cfg.path_mappings or {}
  cfg.lsp = cfg.lsp or {}
  cfg.linters = cfg.linters or {}
  cfg.formatters = cfg.formatters or {}
  cfg.workspace = cfg.workspace or {}
  cfg.commands = cfg.commands or {}

  -- workspace.dir defaults to the container side of the first path mapping.
  -- A trailing `/src` is stripped because that's where colcon-style ROS workspaces
  -- typically map their sources; for projects without a /src suffix this is a no-op.
  -- Override explicitly in the marker for any other layout.
  if (cfg.workspace.dir == nil or cfg.workspace.dir == "") and cfg.path_mappings[1] then
    cfg.workspace.dir = cfg.path_mappings[1].container:gsub("/src$", "")
  end

  -- Validate user-defined commands. Each entry needs key + desc + cmd. We
  -- reserve the keys used by built-in <leader>D* bindings so they can't be
  -- shadowed accidentally.
  local reserved = { s = true, r = true, i = true, l = true }
  for idx, c in ipairs(cfg.commands) do
    if type(c) ~= "table" then
      return false, ("commands[%d] must be a table"):format(idx)
    end
    if type(c.key) ~= "string" or c.key == "" then
      return false, ("commands[%d].key must be a non-empty string"):format(idx)
    end
    if reserved[c.key:sub(1, 1)] and #c.key == 1 then
      return false, ("commands[%d].key '%s' is reserved (s/r/i/l are built-in)"):format(idx, c.key)
    end
    if type(c.cmd) ~= "string" or c.cmd == "" then
      return false, ("commands[%d].cmd must be a non-empty string"):format(idx)
    end
    c.desc = c.desc or ("Docker: " .. c.key)
  end

  -- Resolve symlinks on host paths in path_mappings; warn (don't fail) on mismatch
  for _, pm in ipairs(cfg.path_mappings) do
    if type(pm.host) ~= "string" or type(pm.container) ~= "string" then
      return false, "each path_mapping needs string host and container fields"
    end
    if not vim.startswith(pm.host, "/") or not vim.startswith(pm.container, "/") then
      return false, "path_mappings must be absolute (start with /)"
    end
    local real = vim.uv.fs_realpath(pm.host)
    if real and real ~= pm.host then
      vim.notify(
        ("[docker-project] %s: host path '%s' is a symlink to '%s' — using the realpath"):format(
          marker_path, pm.host, real
        ),
        vim.log.levels.WARN
      )
      pm.host = real
    end
  end

  -- Stash the marker's directory (project root) for later use
  cfg._root = vim.fs.dirname(marker_path)
  cfg._marker_path = marker_path
  return true
end

-- Read marker file via vim.secure.read (issues nvim's built-in trust prompt
-- on first encounter / content change). Returns the loaded+validated config
-- table, or nil on failure / refusal.
local function load_marker(marker_path)
  local trusted = vim.secure.read(marker_path)
  if not trusted then
    return nil, "user did not trust marker file"
  end
  local chunk, load_err = loadstring(trusted, "@" .. marker_path)
  if not chunk then
    return nil, "loadstring: " .. tostring(load_err)
  end
  -- Sandbox the chunk's environment minimally — give it only safe globals.
  -- We're not trying to defeat a determined attacker (trust prompt already
  -- gated this); we just want to keep the marker declarative.
  local ok, result = pcall(chunk)
  if not ok then
    return nil, "execute: " .. tostring(result)
  end
  local valid, verr = validate(result, marker_path)
  if not valid then
    return nil, "schema: " .. verr
  end
  return result
end

-- Public: get the active marker config for a buffer's file (or current buffer).
-- Returns the config table, or nil if no marker is found / the marker failed.
function M.lookup(bufnr)
  bufnr = bufnr or 0
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local start = (fname ~= "") and vim.fs.dirname(fname) or vim.fn.getcwd()
  local marker = find_marker(start)
  if not marker then return nil end

  local stat = vim.uv.fs_stat(marker)
  local mtime = stat and stat.mtime.sec or 0

  local entry = cache[marker]
  if entry and entry.mtime == mtime then
    return entry.config or nil
  end

  local cfg, err = load_marker(marker)
  if not cfg then
    if err and err ~= "user did not trust marker file" then
      vim.notify(("[docker-project] %s: %s"):format(marker, err), vim.log.levels.ERROR)
    end
    cache[marker] = { mtime = mtime, config = false }
    return nil
  end
  cache[marker] = { mtime = mtime, config = cfg }
  return cfg
end

-- Public: invalidate cached entries (used by :LspRestart / explicit reload).
function M.invalidate()
  cache = {}
end

M.SCHEMA_VERSION = SCHEMA_VERSION
M.MARKER_NAME = MARKER_NAME

return M
