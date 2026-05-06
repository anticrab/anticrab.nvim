-- Public API for the per-project Docker LSP / linter / formatter integration.
--
-- A project opts in by placing a `.nvim-docker.lua` file at its root. When such
-- a marker is found (and trusted via vim.secure.read), this module routes
-- configured language servers, linters, and formatters through `docker exec`
-- so they run inside the project's container with the right environment.
--
-- Projects without a marker are completely unaffected — host LSP behaves as
-- before.

local M = {}

local marker = require("core.docker-project.marker")

-- Returns the active config table for the given buffer, or nil.
function M.config(bufnr)
  return marker.lookup(bufnr)
end

-- Returns the project root (directory containing the marker), or nil.
function M.root(bufnr)
  local cfg = marker.lookup(bufnr)
  return cfg and cfg._root or nil
end

-- Returns true iff a marker is active for the given buffer.
function M.is_active(bufnr)
  return marker.lookup(bufnr) ~= nil
end

-- Drop cached marker results (force re-trust / re-load on next lookup).
function M.invalidate()
  marker.invalidate()
end

return M
