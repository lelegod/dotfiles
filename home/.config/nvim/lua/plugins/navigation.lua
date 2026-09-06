return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = {
        enabled = true,
        sources = {
          explorer = { hidden = true, ignored = true },
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
      { '<leader>g', function() Snacks.lazygit() end, desc = 'LazyGit' },
      {
        '<leader>t',
        function()
          Snacks.terminal.toggle(nil, {
            win = {
              position = 'bottom',
              height = 0.3,
              relative = 'win',
              keys = {
                term_normal = {
                  '<esc>',
                  function() vim.cmd('stopinsert') end,
                  mode = 't',
                  expr = false,
                  desc = 'Leave terminal mode',
                },
              },
            },
          })
        end,
        desc = 'Toggle Terminal',
      },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    },
  },
}

