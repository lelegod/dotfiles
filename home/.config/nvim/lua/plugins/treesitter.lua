-- Parsers we actually want on disk. markdown and markdown_inline are the two
-- render-markdown.nvim genuinely requires; the rest just buy better highlighting.
local languages = {
  'markdown', 'markdown_inline',
  'lua', 'vim', 'vimdoc', 'query',
  'bash', 'json', 'yaml', 'toml', 'nix',
  'javascript', 'typescript', 'tsx',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- The master branch's query_predicates.lua calls a node:range() that no
    -- longer exists in Neovim 0.12, which breaks markdown rendering outright.
    -- main is the branch that supports 0.11+.
    branch = 'main',
    lazy = false,  -- upstream states this plugin does not support lazy-loading
    priority = 800,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install(languages)

      -- main drops the old `highlight = { enable = true }` module, so features
      -- get switched on per buffer. pcall keeps this a no-op for filetypes
      -- whose parser we never installed, rather than an error on every open.
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
