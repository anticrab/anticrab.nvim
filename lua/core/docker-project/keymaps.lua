-- <leader>D* keymaps for the active Docker project.
--
-- Built-in (always registered, keys reserved):
--   <leader>Ds — focus / open the persistent docker-shell tab
--   <leader>Dr — restart wrapped LSPs
--   <leader>Di — show project info
--   <leader>Dl — tail container logs (separate floating window)
--
-- Project-defined: every entry of `marker.commands` becomes <leader>D<key>.
-- Each command is sent into a singleton in-container bash via chan_send, so
-- the full output history accumulates and can be scrolled back.

local M = {}

local docker_project = require("core.docker-project")
local docker_exec = require("core.docker-project.exec")

local function require_active()
  local cfg = docker_project.config()
  if not cfg then
    vim.notify("[docker-project] no .nvim-docker.lua marker active for this project", vim.log.levels.WARN)
    return nil
  end
  return cfg
end

-- State for the in-container docker shell. Keyed by the marker path so
-- switching between two Docker-based projects in the same nvim session
-- doesn't reuse the wrong project's shell.
local state = { buf = nil, channel = nil, marker_path = nil }

-- Find any window currently showing the docker buffer (across all tabs).
local function find_window_for_buf(buf)
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(w) == buf then return w end
  end
  return nil
end

-- Reset all state slots (no-op if nothing is alive).
local function reset_state()
  state.buf = nil
  state.channel = nil
  state.marker_path = nil
end

-- Wipe the existing shell buffer if any. Used when switching projects.
local function wipe_existing()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
  end
  reset_state()
end

-- Create the singleton docker terminal in a new tab. Returns true on success,
-- false if the shell couldn't even be spawned (e.g., docker missing).
local function create_term(cfg)
  vim.cmd("tabnew")
  local argv = docker_exec.build(cfg, "bash", { interactive = true })
  local buf = vim.api.nvim_get_current_buf()
  local chan = vim.fn.termopen(argv, {
    on_exit = function()
      -- Shell died (container went down, user `exit`ed, etc.). Reset so the
      -- next <leader>D* spawns a fresh one.
      reset_state()
    end,
  })
  if not chan or chan <= 0 then
    vim.notify(
      ("[docker-project] failed to start shell (termopen rc=%s). Is `docker` on PATH?"):format(chan),
      vim.log.levels.ERROR)
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    return false
  end
  state.buf = buf
  state.channel = chan
  state.marker_path = cfg._marker_path
  pcall(vim.cmd, "file docker-shell")
  vim.bo[buf].buflisted = true
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    buffer = buf,
    once = true,
    callback = reset_state,
  })
  -- Convenience: `q` in normal mode closes the tab (shell keeps running).
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>tabclose<CR>",
    { noremap = true, silent = true })
  return true
end

-- Ensure a singleton shell exists for the *current* project's marker. If a
-- shell from a different project is alive, kill it first.
-- Returns true if a working shell is available.
local function ensure_term(cfg)
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) and state.channel
     and state.marker_path == cfg._marker_path then
    return true
  end
  -- Marker changed (or shell died) — start fresh. But first check that the
  -- container is actually running, otherwise the shell would just exit.
  if not require("core.docker-project.status").is_running(cfg) then
    vim.notify(
      "[docker-project] container is not running. Start it first (e.g., `make up`), then retry.",
      vim.log.levels.WARN)
    return false
  end
  wipe_existing()
  return create_term(cfg)
end

-- Bring the docker shell into view: focus its existing window if any,
-- otherwise open a new tab and switch to it. Returns true on success.
local function focus_term(cfg)
  if not ensure_term(cfg) then return false end
  local win = find_window_for_buf(state.buf)
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd("tabnew")
    vim.api.nvim_set_current_buf(state.buf)
  end
  vim.cmd("startinsert")
  return true
end

-- Send `inner` (a shell command string) to the singleton shell. Opens the tab
-- if not visible. Silently returns when the shell can't be brought up.
local function send_to_term(cfg, inner)
  if not focus_term(cfg) then return end
  vim.api.nvim_chan_send(state.channel, inner .. "\n")
  vim.cmd("startinsert")
end

-- Prepend `cd <workspace.dir>` if workspace.dir is set.
local function with_workspace_cd(cfg, cmd)
  local dir = (cfg.workspace or {}).dir or ""
  if dir == "" then return cmd end
  return ("cd %s && %s"):format(dir, cmd)
end

-- Run a command spec from marker.commands.
local function run_command_spec(cfg, spec)
  if spec.select_from and spec.select_from ~= "" then
    -- Resolve options synchronously inside the container, then prompt.
    local listing = with_workspace_cd(cfg, spec.select_from)
    local rc, out = docker_exec.run(cfg, listing, { timeout = 15000 })
    if rc ~= 0 or not out or out == "" then
      vim.notify(
        ("[docker-project] %s: select_from returned no items (container down?)"):format(spec.key),
        vim.log.levels.WARN)
      return
    end
    local items = {}
    for line in out:gmatch("[^\r\n]+") do
      if line ~= "" then table.insert(items, line) end
    end
    if #items == 0 then
      vim.notify(("[docker-project] %s: no items"):format(spec.key), vim.log.levels.WARN)
      return
    end
    vim.ui.select(items, { prompt = (spec.desc or spec.key) .. ":" }, function(choice)
      if not choice then return end
      local final = spec.cmd:gsub("{pkg}", choice)
      send_to_term(cfg, with_workspace_cd(cfg, final))
    end)
  else
    send_to_term(cfg, with_workspace_cd(cfg, spec.cmd))
  end
end

-- Built-in: focus / open the docker shell.
local function shell_focus()
  local cfg = require_active()
  if not cfg then return end
  focus_term(cfg)
end

-- Built-in: restart wrapped LSP clients.
local function restart_wrapped_lsps()
  local cfg = docker_project.config()
  if not cfg then
    vim.cmd("LspRestart")
    return
  end
  require("core.docker-project.status").invalidate()
  docker_project.invalidate()
  local wrapped = require("core.docker-project.lsp").known_servers()
  for _, srv in ipairs(wrapped) do
    if (cfg.lsp or {})[srv] then vim.cmd("LspRestart " .. srv) end
  end
  vim.notify("[docker-project] restarted: " .. table.concat(wrapped, ", "), vim.log.levels.INFO)
end

-- Built-in: print marker / container summary.
local function show_info()
  local cfg = docker_project.config()
  if not cfg then
    print("[docker-project] no marker active for current buffer.")
    return
  end
  local docker_status = require("core.docker-project.status")
  local lines = {
    "Docker project marker:    " .. (cfg._marker_path or "?"),
    "Project root:             " .. (cfg._root or "?"),
    "Container running:        " .. tostring(docker_status.is_running(cfg)),
    "Service / container:      " .. (cfg.exec.service or cfg.exec.name or "?"),
    "Workspace dir (in cont):  " .. ((cfg.workspace or {}).dir or "(unset)"),
    "Path mappings:",
  }
  for _, pm in ipairs(cfg.path_mappings or {}) do
    table.insert(lines, ("  %s → %s"):format(pm.host, pm.container))
  end
  table.insert(lines, "Wrapped LSPs:             "
    .. table.concat(vim.tbl_keys(cfg.lsp or {}), ", "))
  table.insert(lines, "Linters:                  "
    .. vim.inspect(cfg.linters or {}, { newline = " ", indent = "" }))
  table.insert(lines, "Formatters:               "
    .. vim.inspect(cfg.formatters or {}, { newline = " ", indent = "" }))
  table.insert(lines, ("Docker shell:             %s"):format(
    state.buf and vim.api.nvim_buf_is_valid(state.buf)
      and ("alive (buf #" .. state.buf .. ")") or "(not yet started)"))
  table.insert(lines, "Project commands:")
  for _, c in ipairs(cfg.commands or {}) do
    table.insert(lines, ("  <leader>D%-4s %s"):format(c.key, c.desc or ""))
  end
  print(table.concat(lines, "\n"))
end

-- Built-in: tail container logs in a separate floating Terminal.
-- Logs run via host-side `docker compose logs --follow`, not inside the
-- container, so they don't share the singleton shell.
local function tail_logs()
  local cfg = require_active()
  if not cfg then return end
  if cfg.exec.kind ~= "compose" then
    vim.notify("[docker-project] tail-logs only supported for compose projects", vim.log.levels.WARN)
    return
  end
  local Terminal = require("toggleterm.terminal").Terminal
  local args = { "docker", "compose" }
  if cfg.exec.project_name and cfg.exec.project_name ~= "" then
    table.insert(args, "--project-name") ; table.insert(args, cfg.exec.project_name)
  end
  if cfg.exec.env_file and cfg.exec.env_file ~= "" then
    local f = cfg.exec.env_file
    if not f:match("^/") then f = (cfg._root or "") .. "/" .. f end
    table.insert(args, "--env-file") ; table.insert(args, f)
  end
  local cf = cfg.exec.file
  if cf and not cf:match("^/") then cf = (cfg._root or "") .. "/" .. cf end
  vim.list_extend(args, { "-f", cf, "logs", "--follow", "--tail=200", cfg.exec.service })
  local function shellquote(s) return "'" .. s:gsub("'", [['\'']]) .. "'" end
  local quoted = {}
  for _, p in ipairs(args) do quoted[#quoted + 1] = shellquote(p) end
  local t = Terminal:new({
    cmd = table.concat(quoted, " "),
    direction = "tab",
    hidden = true,
    close_on_exit = false,
    on_open = function() vim.cmd("startinsert!") end,
  })
  t:open()
end

local function register_user_cmd(dual, spec)
  dual("n", "<leader>D" .. spec.key, function()
    local cfg = require_active()
    if not cfg then return end
    run_command_spec(cfg, spec)
  end, { desc = "Docker: " .. (spec.desc or spec.key) })
end

function M.register(dual)
  dual = dual or vim.keymap.set

  dual("n", "<leader>Ds", shell_focus,          { desc = "Docker: focus shell tab" })
  dual("n", "<leader>Dr", restart_wrapped_lsps, { desc = "Docker: restart wrapped LSPs" })
  dual("n", "<leader>Di", show_info,            { desc = "Docker: show project info" })
  dual("n", "<leader>Dl", tail_logs,            { desc = "Docker: tail container logs" })

  local cfg = docker_project.config()
  if cfg and cfg.commands then
    for _, spec in ipairs(cfg.commands) do
      register_user_cmd(dual, spec)
    end
  end
end

return M
