-- In-buffer Markdown rendering: headings, tables, lists, checkboxes, code
-- blocks, callouts — without leaving nvim.
--
-- Editing stays easy: insert & visual modes show the RAW markdown, and
-- anti-conceal keeps the line under the cursor un-rendered in normal mode too,
-- so you always see the source where you're typing. `<leader>m` (set in
-- ftplugin/markdown.lua) or `:RenderMarkdown toggle` flips rendering off
-- entirely when you want the plain source.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  opts = {
    -- Render only in normal/command modes; insert & visual show raw source.
    render_modes = { "n", "c" },
    -- Keep the cursor's line as raw markdown so you can edit it in place.
    anti_conceal = { enabled = true },
  },
}
