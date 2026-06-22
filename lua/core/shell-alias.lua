-- Ensure a `zvim` shell alias (launches Neovim) exists in the user's shell rc.
-- Runs once on startup and is idempotent: if an `alias zvim=` line is already
-- present — added here on a previous run or by hand — it does nothing. Only
-- touches rc files that already exist; it never creates a shell config the user
-- doesn't have.

local M = {}

local ALIAS_NAME = "zvim"
local ALIAS_LINE = "alias zvim='nvim'"
local MARKER = "# Added by anticrab.nvim — launch Neovim with `zvim`"

local function homedir()
  local uv = vim.uv or vim.loop
  return uv.os_homedir()
end

local function ensure_alias_in(path)
  local f = io.open(path, "r")
  if not f then
    return -- rc file doesn't exist; don't create one the user never had
  end
  local contents = f:read("*a") or ""
  f:close()

  -- Already defined (here or manually) → nothing to do.
  if contents:match("alias%s+" .. ALIAS_NAME .. "=") then
    return
  end

  local af = io.open(path, "a")
  if not af then
    return
  end
  -- Separate from preceding content with a blank line for readability.
  local lead = (contents ~= "" and not contents:match("\n$")) and "\n" or ""
  af:write(lead .. "\n" .. MARKER .. "\n" .. ALIAS_LINE .. "\n")
  af:close()
  vim.schedule(function()
    vim.notify(
      "anticrab.nvim: added `zvim` alias to " .. path .. " (open a new shell or `source` it to use)",
      vim.log.levels.INFO
    )
  end)
end

function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      -- Skip headless/scripted runs (e.g. `nvim --headless` in CI) so they
      -- never mutate the user's shell config.
      if #vim.api.nvim_list_uis() == 0 then
        return
      end
      local home = homedir()
      if not home then
        return
      end
      for _, name in ipairs({ ".bashrc", ".zshrc" }) do
        pcall(ensure_alias_in, home .. "/" .. name)
      end
    end,
  })
end

return M
