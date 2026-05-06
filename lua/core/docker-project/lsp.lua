-- LSP hook surface: given a server name and its native cmd, return the
-- container-wrapped cmd (or nil if the server isn't routed through Docker
-- for the current project).

local M = {}

local adapters = {
  clangd  = require("core.docker-project.adapters.clangd"),
  pyright = require("core.docker-project.adapters.pyright"),
}

-- Returns wrapped cmd array, or nil if:
--   - no marker active for the buffer/cwd
--   - the server isn't enabled in the marker
--   - no adapter exists for the server
function M.wrap_cmd(server, native_cmd, cfg)
  if not cfg then return nil end
  local entry = (cfg.lsp or {})[server]
  if not entry or entry.enabled == false then return nil end
  local adapter = adapters[server]
  if not adapter then return nil end
  return adapter.build_cmd(cfg, native_cmd)
end

-- Names of all servers known to the docker-project layer.
function M.known_servers()
  local names = {}
  for k in pairs(adapters) do names[#names + 1] = k end
  return names
end

return M
