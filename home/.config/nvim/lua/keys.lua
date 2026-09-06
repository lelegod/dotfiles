-- save by pressing Escape (only in writable file buffers)
vim.keymap.set('n', '<Esc>', function()
  if vim.bo.buftype == '' and vim.bo.modifiable then
    vim.cmd('w')
  end
end, { desc = 'Save' })
-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
-- pasting over a selection no longer clobbers your clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

