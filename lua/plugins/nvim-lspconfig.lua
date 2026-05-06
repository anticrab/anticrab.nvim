-- LSP Support
return {
  -- LSP Configuration
  -- https://github.com/neovim/nvim-lspconfig
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    -- LSP Management
    -- https://github.com/williamboman/mason.nvim
    { 'williamboman/mason.nvim' },
    -- https://github.com/williamboman/mason-lspconfig.nvim
    { 'williamboman/mason-lspconfig.nvim' },

    -- Useful status updates for LSP
    -- https://github.com/j-hui/fidget.nvim
    { 'j-hui/fidget.nvim', opts = {} },

    -- Additional lua configuration, makes nvim stuff amazing!
    -- https://github.com/folke/neodev.nvim
    { 'folke/neodev.nvim', opts = {} },
  },
  config = function ()
    require('mason').setup()
    require('mason-lspconfig').setup({
      -- Install these LSPs automatically
      ensure_installed = {
        -- 'bashls', -- requires npm to be installed
        -- 'cssls', -- requires npm to be installed
        -- 'html', -- requires npm to be installed
        'lua_ls',
        -- 'jsonls', -- requires npm to be installed
        'lemminx',
        'marksman',
        'quick_lint_js',
        -- 'tsserver', -- requires npm to be installed
        -- 'yamlls', -- requires npm to be installed
        'pyright',
        'clangd',
        -- 'buf-language-server',
      },
      automatic_enable=false,
    })

    local lspconfig = require('lspconfig')
    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lsp_attach = function(client, bufnr)
      -- Create your keybindings here...
    end

    -- Per-server overrides
    local server_settings = {
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = {'vim'},
            },
          },
        },
      },
    }

    -- Per-project Docker integration: when a `.nvim-docker.lua` marker is
    -- present in the cwd's tree, route configured servers through `docker exec`
    -- so they run inside the project's container with ROS2 / build env loaded.
    local docker_project = require("core.docker-project")
    local docker_lsp = require("core.docker-project.lsp")
    local docker_status = require("core.docker-project.status")
    local docker_cfg = docker_project.config()

    local skipped_servers = {}
    if docker_cfg and not docker_status.is_running(docker_cfg) then
      vim.notify(
        ("[docker-project] container is not running for %s — open <leader>Ds and `make up`, then :LspRestart")
          :format(vim.fs.basename(docker_cfg._root or "?")),
        vim.log.levels.WARN
      )
      for _, srv in ipairs(docker_lsp.known_servers()) do
        if (docker_cfg.lsp or {})[srv] and (docker_cfg.lsp[srv].enabled ~= false) then
          skipped_servers[srv] = true
        end
      end
    end

    -- Call setup on each LSP server
    for _, server in ipairs(require("mason-lspconfig").get_installed_servers()) do
      if skipped_servers[server] then
        -- Marker active but container down: skip wrapped server entirely.
        -- (Host LSP would spam errors with no ROS2/std headers visible.)
      else
        local opts = vim.tbl_deep_extend("force", {
          on_attach = lsp_attach,
          capabilities = lsp_capabilities,
        }, server_settings[server] or {})

        local wrapped = docker_lsp.wrap_cmd(server, opts.cmd, docker_cfg)
        if wrapped then
          opts.cmd = wrapped
        end

        lspconfig[server].setup(opts)
      end
    end

    -- Globally configure all LSP floating preview popups (like hover, signature help, etc)
    local open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or "rounded" -- Set border to rounded
      return open_floating_preview(contents, syntax, opts, ...)
    end

  end
}
