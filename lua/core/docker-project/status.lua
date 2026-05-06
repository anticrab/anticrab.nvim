-- Cached "is the project's container actually running?" check.
--
-- We hit `docker compose ... ps --services --status running` for compose
-- projects, or `docker inspect -f {{.State.Running}}` for raw containers.
-- The result is cached for STATUS_TTL_MS so we don't shell out on every
-- BufEnter. M.invalidate() clears the cache (called by :LspRestart hooks).

local M = {}

local STATUS_TTL_MS = 5000

-- Cache: marker_path → { running = bool, checked_at = ms }
local cache = {}

local function now_ms()
  return vim.uv.hrtime() / 1e6
end

local function check_compose(cfg)
  local exec = cfg.exec
  local args = { "docker", "compose" }
  if exec.project_name and exec.project_name ~= "" then
    table.insert(args, "--project-name") ; table.insert(args, exec.project_name)
  end
  if exec.env_file and exec.env_file ~= "" then
    table.insert(args, "--env-file") ; table.insert(args, exec.env_file)
  end
  vim.list_extend(args, {
    "-f", exec.file, "ps", "--services", "--status", "running",
  })
  local res = vim.system(args, { cwd = cfg._root, text = true, timeout = 5000 }):wait()
  if res.code ~= 0 then return false end
  for line in (res.stdout or ""):gmatch("[^\r\n]+") do
    if line == exec.service then return true end
  end
  return false
end

local function check_container(cfg)
  local res = vim.system(
    { "docker", "inspect", "-f", "{{.State.Running}}", cfg.exec.name },
    { text = true, timeout = 5000 }
  ):wait()
  if res.code ~= 0 then return false end
  return (res.stdout or ""):match("true") ~= nil
end

-- Returns true iff the container described by `cfg` is currently running.
-- Uses a 5-second cache to avoid hammering the docker daemon.
function M.is_running(cfg)
  if not cfg then return false end
  local key = cfg._marker_path or "?"
  local entry = cache[key]
  if entry and (now_ms() - entry.checked_at) < STATUS_TTL_MS then
    return entry.running
  end

  local running
  if cfg.exec.kind == "compose" then
    running = check_compose(cfg)
  else
    running = check_container(cfg)
  end

  cache[key] = { running = running, checked_at = now_ms() }
  return running
end

function M.invalidate()
  cache = {}
end

return M
