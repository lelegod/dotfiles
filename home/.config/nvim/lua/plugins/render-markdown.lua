return {
  {
    -- VSCode previews markdown in a separate read-only pane, so you scroll two
    -- things at once. This renders headings, tables, code blocks and checkboxes
    -- in the buffer you are still editing.
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },
    ft = { 'markdown' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
}
