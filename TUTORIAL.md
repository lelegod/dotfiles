# My Setup — A Working Tutorial

A guide to *this* machine's actual config. Every keybinding and default below was
read out of the config files or the installed plugin source, not from memory.

Leader key is <kbd>Space</kbd> (`lua/vim_config.lua:2`).

---

## 1. The Map

```
dotfiles/
├── configuration.nix              # system-level (nix-darwin)
├── home.nix                       # packages + symlinks
├── flake.nix
└── home/.config/
    ├── nvim/
    │   ├── init.lua               # requires the 3 files below, in order
    │   ├── lua/vim_config.lua     # options (leader, indent, mouse, clipboard)
    │   ├── lua/plugin.lua         # bootstraps lazy.nvim
    │   ├── lua/keys.lua           # my own keymaps
    │   └── lua/plugins/*.lua      # one file per concern, auto-imported
    ├── wezterm/wezterm.lua
    └── herdr/config.toml
```

**Editing is live.** `~/.config/nvim`, `~/.config/wezterm`, and `~/.config/herdr`
are out-of-store symlinks back into this repo (`home.nix:54-60`), so saving a file
here takes effect immediately. No `home-manager switch` needed for config edits —
only for changes to `home.nix` / `configuration.nix` themselves.

**Adding a plugin** = drop a new file in `lua/plugins/` returning a spec table.
`require('lazy').setup('plugins')` (`lua/plugin.lua:7`) imports every file in that
directory automatically. Restart nvim and lazy installs it.

### Installed plugins

| Plugin | Job |
| --- | --- |
| `rose-pine` | colorscheme (`priority = 1000`, loads first) |
| `mini.icons` | filetype icons for oil + all snacks pickers |
| `oil.nvim` | file manager — edit a directory like a buffer |
| `snacks.nvim` | pickers, notifier, input (explorer available but off) |
| `neogit` + `diffview` | git UI |
| `gitsigns` | gutter signs + inline blame |
| `which-key` | popup showing what leader keys do |
| `plenary` | dependency of neogit |

---

## 2. Options That Change How Everything Feels

From `lua/vim_config.lua`:

| Setting | Effect |
| --- | --- |
| `mapleader = ' '` | Space is leader |
| `mouse = ''` | **No mouse in nvim at all** — no click, no wheel scroll |
| `clipboard = 'unnamedplus'` | yank/paste shares the macOS clipboard automatically |
| `number` + `relativenumber` | hybrid numbers: absolute on cursor line, relative elsewhere |
| `scrolloff = 16` | screen scrolls to keep 16 lines of context around the cursor |
| `ignorecase` + `smartcase` | search is case-insensitive unless you type a capital |
| `undofile = true` | undo history survives closing the file |
| `expandtab`, `shiftwidth = 2` | 2 spaces, never tabs |

Two of these matter more than they look:

- **`mouse = ''`** means every bit of navigation is keyboard. Intentional, but it's
  why clicking in nvim does nothing.
- **`relativenumber`** is what makes `d5j`, `12k`, `3dd` practical — the number you
  need is printed next to the line you're aiming at.
- **`undofile`** means `u` works even after reopening a file. Nothing is lost.

---

## 3. Vim Editing — The Actual Model

### Modes

| Key | Goes to |
| --- | --- |
| `i` / `a` | insert (before / after cursor) |
| `o` / `O` | insert on a new line below / above |
| `v` / `V` / `<C-v>` | visual char / line / block |
| `<Esc>` | back to normal — **but see the gotcha below** |
| `:` | command line |

### Operator + motion

The core idea. `d` is not "delete line" — it's the *delete operator*, waiting to
hear what to delete.

```
d + w  → to next word        c + w  → change word
d + $  → to end of line      y + $  → yank to end of line
d + }  → to end of paragraph  > + }  → indent paragraph
d + G  → to end of file
```

Learn a motion once and it works with every operator: `d` (delete), `c` (change),
`y` (yank), `>` / `<` (indent), `gu` / `gU` (case).

### Text objects — where the speed is

`d`/`c`/`y` + `i` (inside) or `a` (around) + the thing:

| Command | Target |
| --- | --- |
| `diw` / `daw` | inside word / around word (incl. trailing space) |
| `di"` `di'` | inside quotes |
| `di(` `di{` `di[` | inside brackets |
| `dip` | the paragraph/block |
| `dit` | inside an HTML/XML tag |
| `ci{` | **change** inside braces — the classic drill |

Cursor anywhere inside `foo("hello world")`, press `di"` → `foo("")`.

### Line-level

| Command | Does |
| --- | --- |
| `dd` / `3dd` | delete 1 / 3 lines |
| `yy` / `p` / `P` | copy line / paste after / paste before |
| `D` / `C` | delete / change to end of line |
| `J` | join this line with the next |
| `u` / `<C-r>` | undo / redo |
| `.` | repeat last change |

`.` is the most underrated key in vim. `ciwfoo<Esc>` then `n.` `n.` `n.` renames
occurrence by occurrence.

### Moving

| Key | Motion |
| --- | --- |
| `w` / `b` / `e` | word forward / back / to end of word |
| `0` / `^` / `$` | line start / first non-blank / line end |
| `gg` / `G` | top / bottom of file |
| `{` / `}` | previous / next paragraph |
| `<C-d>` / `<C-u>` | half page down / up |
| `f<char>` / `t<char>` | jump to / just before next `<char>` on the line |
| `%` | jump to matching bracket |
| `<C-o>` / `<C-i>` | jump back / forward through jump history |
| `*` | search for the word under the cursor |

`<C-o>` / `<C-i>` work across files and across oil directories — it's your
browser back/forward button.

### My custom keymaps (`lua/keys.lua`)

| Key | Does | Note |
| --- | --- | --- |
| `<Esc>` | `:w` — save | normal mode only; see gotcha |
| `<C-a>` | `ggVG` — select whole file | |
| `p` in visual | paste without clobbering the clipboard | lets you stamp the same yank repeatedly |

---

## 4. Files — oil.nvim

`<leader>e` opens oil on the current directory.

**The model:** a directory is a text buffer. Edit the text, save, and oil makes the
filesystem match. There are no special create/rename/delete commands — you already
know them.

| Goal | Do this |
| --- | --- |
| New file | `o`, type `notes.txt`, save |
| New folder | `o`, type `stuff/` — **trailing slash means folder** |
| Nested path | `o`, type `a/b/c/file.txt` — creates the whole chain |
| Rename | edit the name in place (`cw`, `A`, `ciw`), save |
| Delete | `dd` the line, save |
| Move | `dd` here, navigate elsewhere, `p`, save |
| Copy | `yy`, navigate, `p`, save |

Move and copy work **across** oil buffers — `dd` a file, walk to another directory,
`p`, save. That's a `mv`.

### Navigating oil

| Key | Does |
| --- | --- |
| `<CR>` | enter directory / open file |
| `-` | go **up** to parent |
| `_` | jump to cwd |
| `<C-c>` | close oil |
| `<C-p>` | preview pane |
| `<C-s>` / `<C-h>` / `<C-t>` | open in vsplit / split / new tab |
| `g?` | show all keymaps |
| `g.` | toggle hidden files |
| `gs` | change sort |
| `` ` `` | `:cd` to this directory |

`-` is "up a level" (tree position). `<C-o>` is "back where I came from" (history).
Different things — you want both.

> **`<CR>`** is vim notation for the **Enter key**. Same family: `<Esc>`, `<Tab>`,
> `<Space>`, `<C-o>` = Ctrl+o, `<leader>` = Space here.

---

## 5. Finding Things — snacks pickers

| Key | Picker |
| --- | --- |
| `<leader>f` | find files by name |
| `<leader>s` | grep file contents |
| `<leader>b` | open buffers |
| `gd` | LSP go-to-definition |

Backed by `fd` and `rg` (`home.nix:12-13`). Inside a picker: type to filter,
`<C-n>`/`<C-p>` or arrows to move, `<CR>` to open, `<Esc>` to cancel.

`<leader>s` is usually the fastest way to get anywhere in an unfamiliar repo —
search for a string you know exists rather than guessing the filename.

---

## 6. Git

| Key | Does |
| --- | --- |
| `<leader>g` | open Neogit |

In Neogit: `s` stage, `u` unstage, `c c` commit, `P p` push, `p p` pull, `$` show
git output, `q` close. `Tab` expands a diff under the cursor.

`gitsigns` runs on every buffer with `current_line_blame = true`
(`lua/plugins/git.lua:12`) — the author of the current line shows at end of line.

---

## 7. WezTerm

Config at `home/.config/wezterm/wezterm.lua`: Hack Nerd Font 15pt, 80% opacity,
blur 50, tab bar hidden when only one tab, `RESIZE` decorations.

| Keys | Does |
| --- | --- |
| `Cmd+T` / `Cmd+W` | new tab / close tab |
| `Cmd+1`…`Cmd+9` | jump to tab N |
| `Cmd+F` | search scrollback |
| `Shift+PageUp` / `Shift+PageDown` | scroll a page (`Fn+Shift+↑/↓` on a MacBook) |
| `Ctrl+Shift+X` | copy mode — vim motions over the scrollback |
| `Cmd+K` | clear scrollback |

Copy mode gives you `j`/`k`, `Ctrl+f`/`Ctrl+b` (page), `Ctrl+d` (half page),
`g`/`G` (top/bottom of scrollback), `H`/`M`/`L` (viewport top/mid/bottom),
`V` (line select), `Escape` to exit. Free vim practice.

The tab bar appears only when a second tab exists, because
`hide_tab_bar_if_only_one_tab = true`. If a tab bar "suddenly appears," something
opened a second tab — that's the cause.

---

## 8. Gotchas — Verified, Worth Knowing

### `<Esc>` saves the file

`keys.lua:2` maps `<Esc>` to `:w` **in normal mode**. Leaving insert mode works
normally, but a *second* `Esc` writes to disk. Reflexive Esc-mashing means
constant saves.

In an oil buffer, saving is how oil *commits* filesystem changes — so `Esc` is
effectively your "apply" key there. Oil shows a confirmation listing every
operation first, so nothing happens silently.

If you see **`E382: Cannot write, 'buftype' option is set`**, that's this mapping
firing in a buffer that can't be written (a help page, a picker, a preview). It's
harmless — nothing was lost, nothing was saved.

### oil deletes are permanent

`delete_to_trash` defaults to `false`. `dd` + save is a real `rm`, not a move to
trash. If you want a safety net, add `delete_to_trash = true` to the oil `opts` in
`lua/plugins/navigation.lua`.

### oil hijacks directory buffers

`default_file_explorer = true` by default, so `nvim .` and `:e src/` open oil
instead of netrw. Worth knowing if you ever add a second file explorer — snacks'
explorer has `replace_netrw = true` and the two would fight over `BufEnter`.

### Terminal scrollback does not work inside Claude Code

Measured, not assumed. Requesting 10,000 lines of scrollback from the Claude Code
pane returns exactly the viewport height — same as nvim, and unlike a plain shell
pane which returned all 300 test lines:

| Pane | Viewport | Scrollback requested |
| --- | --- | --- |
| plain zsh (control, printed 300 lines) | 37 | **306** |
| nvim | 35 | 35 |
| Claude Code 2.1.220 | 35 | 35 |

Claude Code runs in the **alternate screen buffer** (confirmed: `?1049` present in
the binary), which has no scrollback by design. So `Shift+PageUp`, `Ctrl+Shift+X`
copy mode, and raising `scrollback_lines` cannot help — there is nothing stored to
scroll back to. Scrolling has to be handled by Claude Code itself.

*Open question:* the binary contains no `?1002`/`?1003` (the mouse modes needed for
wheel reporting), and the `ctrl+u`/`ctrl+d` scroll hint found in it belongs to a
plan-selection dialog, not the main transcript. The correct way to scroll the
conversation is still unresolved — investigation was cut short.

### mini.icons must be *set up*, not just installed

Both oil and snacks check for the **global** `_G.MiniIcons`, not the module. Oil is
explicit about it (`oil/util.lua:832`: *"`_G.MiniIcons` is a better check to see if
the module is setup"*). That's why the spec has `opts = {}` — lazy.nvim turns that
into a `setup()` call, which creates the global. Drop `opts` and you get a silently
icon-less setup.

---

## 9. Practice Path

1. **`u`** — internalize that nothing is permanent.
2. **`dd`, `yy`, `p`** — line surgery.
3. **`V` + motion + `d`** — visual selection, because you can see it.
4. **`diw`, `di"`, `ci{`** — text objects. This is the real unlock.
5. **`f<char>`, `%`, `<C-o>`** — precision movement.
6. **`.`** — repeat. Combine with `ciw` for cheap renames.

Do this in a scratch file, not real code. `<leader>e`, make a `practice/` folder,
work in there.

Want a game instead: `vim-be-good` is a plugin that drills exactly these. Note its
README shows `Plug '...'` (vim-plug syntax) — this setup uses lazy.nvim, so the
spec would be a new file in `lua/plugins/` with `cmd = 'VimBeGood'`.
