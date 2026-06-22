-- Markdown specific settings
vim.opt.wrap = true -- Wrap text
vim.opt.breakindent = true -- Match indent on line break
vim.opt.linebreak = true -- Line break on whole words

-- Allow j/k when navigating wrapped lines
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Spell check
vim.opt.spelllang = 'en_us'
vim.opt.spell = false

-- Toggle the rendered markdown view (render-markdown.nvim) when you want the
-- plain source instead of the inline render.
vim.keymap.set("n", "<leader>m", "<cmd>RenderMarkdown toggle<CR>",
  { buffer = true, silent = true, desc = "Toggle markdown render" })
