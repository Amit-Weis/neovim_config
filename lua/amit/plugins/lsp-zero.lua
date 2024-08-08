return {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v4.x',
    dependencies = {
      { 'neovim/nvim-lspconfig' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-buffer' },
      { 'L3MON4D3/LuaSnip' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'rafamadriz/friendly-snippets' },
    },
    config = function()
      local lsp_zero = require('lsp-zero')
      local cmp = require('cmp')
      require('luasnip.loaders.from_vscode').lazy_load()
      local cmp_action = require('lsp-zero').cmp_action()
      local cmp_format = require('lsp-zero').cmp_format({ details = true })
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          -- confirm completion
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        }),
      })
      cmp.setup({
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        }),
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        --- (Optional) Show source name in completion menu
        formatting = cmp_format,
      })

      -- lsp_attach is where you enable features that only work
      -- if there is a language server active in the file
      local lsp_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        lsp_zero.buffer_autoformat()
        vim.keymap.set('i', '<C-j>', '<Down>', opts)
        vim.keymap.set('i', '<C-k>', '<Up>', opts)

        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set({ 'n', 'x' }, 'gq', function()
          vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
        end, opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
      end

      require('mason').setup({})
      require('mason-lspconfig').setup({
        -- Replace the language servers listed here
        -- with the ones you want to install
        ensure_installed = { 'lua_ls', 'rust_analyzer', 'csharp_ls', 'clangd', 'cssls', 'html', 'tsserver', 'jsonls', 'ltex', 'powershell_es', 'pylsp' },
        handlers = {
          function(server_name)
            local lspconfig = require('lspconfig')
            local opts = {
              on_attach = lsp_attach,
              capabilities = require('cmp_nvim_lsp').default_capabilities(),
            }

            -- Additional specific configurations for certain servers
            if server_name == 'lua_ls' then
              opts.settings = {
                Lua = {
                  runtime = { version = 'LuaJIT' },
                  workspace = {
                    checkThirdParty = false,
                    library = { vim.env.VIMRUNTIME },
                  },
                  telemetry = { enable = false },
                }
              }
              opts.on_init = function(client)
                local path = client.workspace_folders[1].name
                if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                  return
                end
                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                  runtime = { version = 'LuaJIT' },
                  workspace = {
                    checkThirdParty = false,
                    library = { vim.env.VIMRUNTIME },
                  },
                })
              end
            end

            lspconfig[server_name].setup(opts)
          end,
        },
      })
    end
  }
}
