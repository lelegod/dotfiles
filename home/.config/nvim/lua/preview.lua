-- <leader>p previews the current file the way VSCode would.
--
-- VSCode can show a PDF or a spreadsheet because it is Electron: it ships a whole
-- browser engine and its previewers are web apps drawing into a tab. Terminal nvim
-- has no rendering engine, and WezTerm does not support inline images, so rather
-- than fake it badly each file type is handed to whatever actually renders it well.

local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'Preview' })
end

local function missing(tool, package)
  notify(('%s not found. Add `%s` to home.nix, then run ./rebuild.sh.'):format(tool, package),
    vim.log.levels.ERROR)
end

-- Hand the file to macOS and let it pick. For PDFs that is Preview.app, which
-- renders as faithfully as VSCode does and costs us no dependency.
local function open_external(path)
  vim.system({ 'open', path }, { text = true }, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        notify('open failed: ' .. ((res.stderr or ''):gsub('%s+$', '')), vim.log.levels.ERROR)
      end)
    end
  end)
end

-- visidata is a full-screen TUI, so it needs a real terminal to draw into,
-- not a scratch buffer. It reads .xlsx directly via openpyxl, no conversion.
local function open_visidata(path)
  if vim.fn.executable('vd') == 0 then
    return missing('visidata', 'visidata')
  end
  Snacks.terminal.open({ 'vd', path }, {
    win = {
      position = 'float',
      width = 0.95,
      height = 0.95,
      border = 'rounded',
      title = ' ' .. vim.fn.fnamemodify(path, ':t') .. ' ',
      title_pos = 'center',
    },
  })
end

-- -layout preserves column positions, which is what makes tables survive the trip.
function M.pdf_text(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if vim.fn.executable('pdftotext') == 0 then
    return missing('pdftotext', 'poppler-utils')
  end
  local res = vim.system({ 'pdftotext', '-layout', path, '-' }, { text = true }):wait()
  if res.code ~= 0 then
    return notify('pdftotext failed: ' .. ((res.stderr or ''):gsub('%s+$', '')), vim.log.levels.ERROR)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(res.stdout, '\n', { plain = true }))
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_set_name(buf, path .. ' [text]')
  vim.cmd('vsplit')
  vim.api.nvim_win_set_buf(0, buf)
end

local by_extension = {
  pdf = open_external,

  xlsx = open_visidata,
  xlsm = open_visidata,
  xls  = open_visidata,
  ods  = open_visidata,
  csv  = open_visidata,
  tsv  = open_visidata,

  md       = function() vim.cmd('MarkdownPreview') end,
  markdown = function() vim.cmd('MarkdownPreview') end,

  docx = open_external,
  pptx = open_external,
  png  = open_external,
  jpg  = open_external,
  jpeg = open_external,
  gif  = open_external,
  svg  = open_external,
}

-- Opening a binary in nvim dumps raw bytes into the buffer. VSCode never shows
-- you those, so intercept the read and route straight to the previewer instead.
-- Text-ish formats (csv, tsv, md, svg) are deliberately absent: those belong in nvim.
vim.api.nvim_create_autocmd('BufReadCmd', {
  pattern = {
    '*.pdf', '*.PDF',
    '*.xlsx', '*.xlsm', '*.xls', '*.ods',
    '*.docx', '*.pptx',
    '*.png', '*.jpg', '*.jpeg', '*.gif',
  },
  callback = function(ev)
    local handler = by_extension[vim.fn.fnamemodify(ev.file, ':e'):lower()]
    if handler then
      handler(ev.file)
    end
    -- Drop the empty placeholder buffer so it never lands in the buffer list.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end
    end)
  end,
})

function M.preview()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    return notify('This buffer is not a file.', vim.log.levels.WARN)
  end
  if vim.fn.filereadable(path) == 0 then
    return notify('Not readable on disk: ' .. path, vim.log.levels.WARN)
  end

  local ext = vim.fn.fnamemodify(path, ':e'):lower()
  local handler = by_extension[ext]
  if not handler then
    return notify(('No previewer for %s files.'):format(ext ~= '' and '.' .. ext or 'extensionless'),
      vim.log.levels.WARN)
  end
  handler(path)
end

vim.keymap.set('n', '<leader>p', M.preview, { desc = 'Preview file' })
vim.api.nvim_create_user_command('PdfText', function() M.pdf_text() end,
  { desc = 'Extract the current PDF to a scratch buffer' })

return M
