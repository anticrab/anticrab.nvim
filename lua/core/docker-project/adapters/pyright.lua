-- pyright adapter — runs `pyright-langserver --stdio` inside the container.
-- Container picks up ROS2 Python deps because setup_cmd sources the workspace.
--
-- Unlike clangd, pyright has NO path-mapping flag, so it receives the editor's
-- *host* paths (e.g. /home/me/projects/foo/src/...) which don't exist inside
-- the container — pyright then dies with "File or directory ... does not exist".
-- We bridge that by symlinking each mapping's host path to its container path
-- before launching the server, so host paths resolve to the bind-mounted tree.
-- `mkdir -p` / `ln -sfn` are idempotent, so doing this on every launch is safe.
-- The commands print nothing on success, so they don't corrupt pyright's stdio.

local exec = require("core.docker-project.exec")

local M = {}

-- Shell snippet (with trailing " && ") that makes host paths resolve in the
-- container, or "" when there are no mappings.
local function symlink_prefix(cfg)
  local cmds = {}
  for _, pm in ipairs(cfg.path_mappings or {}) do
    local host_parent = vim.fn.fnamemodify(pm.host, ":h")
    cmds[#cmds + 1] = ("mkdir -p %s && ln -sfn %s %s"):format(
      vim.fn.shellescape(host_parent),
      vim.fn.shellescape(pm.container),
      vim.fn.shellescape(pm.host)
    )
  end
  if #cmds == 0 then return "" end
  return table.concat(cmds, " && ") .. " && "
end

function M.build_cmd(cfg, _native_cmd)
  return exec.build(cfg, symlink_prefix(cfg) .. "pyright-langserver --stdio")
end

return M
