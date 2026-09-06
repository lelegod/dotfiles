return {
  {
    -- Opening a .csv should just show a table, the way it does in VSCode.
    'hat0uma/csvview.nvim',
    ft = { 'csv', 'tsv' },
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
    ---@module 'csvview'
    ---@type CsvView.Options
    opts = {
      parser = { comments = { '#', '//' } },
      view = { display_mode = 'border' },
    },
    config = function(_, opts)
      require('csvview').setup(opts)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'csv', 'tsv' },
        callback = function() require('csvview').enable() end,
      })
      -- The autocmd above misses the very buffer whose FileType triggered this load.
      if vim.tbl_contains({ 'csv', 'tsv' }, vim.bo.filetype) then
        require('csvview').enable()
      end
    end,
  },
}
