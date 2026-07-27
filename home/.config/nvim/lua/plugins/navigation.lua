return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = { 
        enabled = true,
        sources = {
          explorer = { hidden = true },
          ignored = { hidden = true },
        },
      },
      notifier = { enabled = true },
      input = { enabled = true },
      explorer = {},
    },
    keys = {
      { '<leader>f', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>s', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>e', function() Snacks.picker.explorer() end, desc = 'File Explorer' },
      { '<leader>E', function() Snacks.explorer.reveal() end, desc = 'Reveal in Explorer' },
      { '<leader>t', function() Snacks.terminal.toggle() end, desc = 'Toggle Terminal' },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    },
  },
}

