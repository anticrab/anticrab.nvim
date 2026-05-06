-- clangd adapter: build the in-container invocation with --path-mappings.
--
-- clangd's path-mappings flag rewrites paths in BOTH directions at the LSP
-- boundary. Syntax (clangd ≥12):
--   clangd --path-mappings=<host1>=<container1>,<host2>=<container2>
-- Host prefix must match exactly how nvim emits file:// URIs (no trailing
-- slash, symlinks resolved).

local exec = require("core.docker-project.exec")

local M = {}

local function build_mappings(cfg)
  local pairs_ = {}
  for _, pm in ipairs(cfg.path_mappings or {}) do
    table.insert(pairs_, ("%s=%s"):format(pm.host, pm.container))
  end
  if #pairs_ == 0 then return nil end
  return table.concat(pairs_, ",")
end

-- Pick the in-container directory where compile_commands.json lives.
-- Resolution order:
--   1. cfg.lsp.clangd.compile_commands_dir (explicit override)
--   2. cfg.workspace.dir (the project's in-container working directory)
--   3. nil — clangd will fall back to walking upward from each opened file.
local function default_cc_dir(cfg)
  local entry = (cfg.lsp or {}).clangd or {}
  if entry.compile_commands_dir and entry.compile_commands_dir ~= "" then
    return entry.compile_commands_dir
  end
  local ws_dir = (cfg.workspace or {}).dir
  if ws_dir and ws_dir ~= "" then return ws_dir end
  return nil
end

-- Returns a `cmd` array (Lua list of strings) for vim.lsp.start_client / lspconfig.
function M.build_cmd(cfg, _native_cmd)
  local mappings = build_mappings(cfg)
  local cc_dir = default_cc_dir(cfg)
  local inner = "clangd"
  if mappings then
    inner = inner .. " --path-mappings=" .. mappings
  end
  if cc_dir then
    inner = inner .. " --compile-commands-dir=" .. cc_dir
  end
  return exec.build(cfg, inner)
end

return M
