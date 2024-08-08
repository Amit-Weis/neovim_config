return {
  -- Add other plugins here

  -- Add rose-pine colorscheme plugin
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    config = function()
      require('rose-pine').setup({
        disable_italics = true,
        dim_nc_background = true
      })
      -- Set the colorscheme
      vim.cmd('colorscheme rose-pine')
    end
  }
}


