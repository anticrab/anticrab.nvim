-- :checkhealth core.docker-project
-- Reports marker / container / compile_commands / latency state.

local M = {}

local h = vim.health

function M.check()
  h.start("core.docker-project")

  local ok_secure = type(vim.secure) == "table" and type(vim.secure.read) == "function"
  if not ok_secure then
    h.error("vim.secure.read not available — marker trust prompt won't work; nvim ≥0.9 required")
  end

  local docker_project = require("core.docker-project")
  local cfg = docker_project.config()

  if not cfg then
    h.info(("no `.nvim-docker.lua` marker found from cwd `%s`"):format(vim.fn.getcwd()))
    h.info("this is expected for non-container projects; ignore if you weren't expecting one")
    return
  end

  h.ok(("marker: %s"):format(cfg._marker_path))
  h.info(("project root: %s"):format(cfg._root))
  h.info(("schema: v%d"):format(cfg.schema_version))

  -- docker present?
  if vim.fn.executable("docker") == 0 then
    h.error("`docker` binary not found in PATH")
    return
  else
    h.ok("`docker` is on PATH")
  end

  -- compose file exists?
  if cfg.exec.kind == "compose" then
    local cf = cfg._root .. "/" .. cfg.exec.file
    if vim.uv.fs_stat(cf) then
      h.ok(("compose file: %s"):format(cf))
    else
      h.error(("compose file not found: %s"):format(cf))
    end
  end

  -- container running?
  local docker_status = require("core.docker-project.status")
  docker_status.invalidate()
  if docker_status.is_running(cfg) then
    h.ok("container is running")
  else
    h.warn("container is NOT running — `<leader>Ds` shell or `make up`, then `:LspRestart`")
    return -- subsequent checks need a live container
  end

  -- in-container clangd reachable?
  local docker_exec = require("core.docker-project.exec")
  local rc, _, _ = docker_exec.run(cfg, "clangd --version > /dev/null 2>&1", { timeout = 8000 })
  if rc == 0 then
    h.ok("clangd reachable inside container")
  else
    h.warn("clangd not found inside container (apt install clangd?)")
  end

  -- compile_commands.json check (only if a workspace.dir is known; otherwise skip).
  -- We probe inside the container because build/ is typically container-only.
  local ws_dir = (cfg.workspace or {}).dir
  if ws_dir and ws_dir ~= "" then
    local probe = ("test -f %s/compile_commands.json && echo aggregated; "
                .. "find %s -mindepth 1 -maxdepth 4 -name compile_commands.json 2>/dev/null | wc -l")
                :format(ws_dir, ws_dir)
    local _, ccq = docker_exec.run(cfg, probe)
    local lines = {}
    for line in (ccq or ""):gmatch("[^\r\n]+") do table.insert(lines, line) end
    local aggregated = false
    local total = 0
    for _, line in ipairs(lines) do
      if line == "aggregated" then aggregated = true
      else total = tonumber(line) or total end
    end
    if aggregated then
      h.ok(("aggregated compile_commands.json present at %s (~%d total found)"):format(ws_dir, total))
    elseif total > 0 then
      h.warn(("found %d compile_commands.json under %s but no aggregated one — run `<leader>Db`"):format(total, ws_dir))
    else
      h.info(("no compile_commands.json yet under %s — run `<leader>Db` if your project needs one"):format(ws_dir))
    end
  else
    h.info("workspace.dir not configured — compile_commands check skipped")
  end

  -- latency probe
  local t0 = vim.uv.hrtime()
  local rc2, _ = docker_exec.run(cfg, "true", { timeout = 5000 })
  local ms = (vim.uv.hrtime() - t0) / 1e6
  if rc2 == 0 then
    if ms > 1500 then
      h.warn(("latency: %.0f ms (slow — first exec? compose resolve overhead)"):format(ms))
    else
      h.ok(("latency: %.0f ms (round-trip noop)"):format(ms))
    end
  else
    h.error("latency probe failed")
  end

  -- path mappings sanity
  for _, pm in ipairs(cfg.path_mappings or {}) do
    if vim.uv.fs_stat(pm.host) then
      h.ok(("mapping: %s → %s"):format(pm.host, pm.container))
    else
      h.warn(("host path missing: %s (was the project moved?)"):format(pm.host))
    end
  end
end

return M
