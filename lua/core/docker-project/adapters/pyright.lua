-- pyright adapter — runs `pyright-langserver --stdio` inside the container.
-- Container picks up ROS2 Python deps because setup_cmd sources the workspace.

local exec = require("core.docker-project.exec")

local M = {}

function M.build_cmd(cfg, _native_cmd)
  return exec.build(cfg, "pyright-langserver --stdio")
end

return M
