return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        style = 'night',
        -- Opaque on purpose: wezterm runs the same palette, so letting nvim paint
        -- its own background costs nothing and keeps every bg-based highlight intact
        transparent = false,
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
        },
        on_colors = function(colors)
          -- The stock comment (#565f89) is 2.8:1 against this background, well under
          -- the 4.5:1 readability floor. This is tokyonight-moon's fg_dark, at 5.2:1.
          colors.comment = '#828bb8'
        end,
        on_highlights = function(hl, colors)
          -- Everything below is held to the same 4.5:1 floor as the comment above.
          hl.LineNr = { fg = colors.comment }   -- stock #3b4261 is 1.7:1, near invisible
          hl.SnacksPickerDir = { fg = colors.comment }  -- snacks defaults this to NonText, 2.6:1
        end,
      })

      vim.cmd('colorscheme tokyonight')
    end,
  },
}
