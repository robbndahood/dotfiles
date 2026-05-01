# Neovim + VSCode Keybindings Cheat Sheet

> **Leader Key:** `Space`
> 
> **Quick Escape:** `jk` (in insert mode)

---

## 📂 File Operations

| Keybinding | Action | Context |
|------------|--------|---------|
| `<leader>w` | Save file | Normal |
| `<leader>e` | Toggle file explorer (NvimTree/VSCode Explorer) | Normal |

---

## 🔍 Find & Search

### Find Operations (`<leader>f` prefix)

| Keybinding | Action | VSCode Equivalent |
|------------|--------|-------------------|
| `<leader>ff` | Find files | Quick Open |
| `<leader>fg` | Find string (live grep) | Search in files |
| `<leader>fb` | Find buffers | Recent files |
| `<leader>fh` | Find help/commands | Command palette |

---

## 🪟 Window/Pane Navigation

### Editor Group Navigation (works in both modes)

| Keybinding | Action |
|------------|--------|
| `Ctrl-h` | Focus left editor group/window |
| `Ctrl-j` | Focus below editor group/window |
| `Ctrl-k` | Focus above editor group/window |
| `Ctrl-l` | Focus right editor group/window |

### Window Resizing (Neovim only, not VSCode)

| Keybinding | Action |
|------------|--------|
| `Ctrl-Up` | Increase window height |
| `Ctrl-Down` | Decrease window height |
| `Ctrl-Left` | Decrease window width |
| `Ctrl-Right` | Increase window width |

---

## 📜 Scrolling

| Keybinding | Action |
|------------|--------|
| `Ctrl-u` | Scroll up half page |
| `Ctrl-d` | Scroll down half page |

---

## 📄 Buffer Navigation (Neovim only, not VSCode)

| Keybinding | Action |
|------------|--------|
| `Shift-l` | Next buffer |
| `Shift-h` | Previous buffer |

---

## ✏️ Editing Operations

### Insert Mode

| Keybinding | Action |
|------------|--------|
| `jk` | Exit insert mode (Escape alternative) |

### Normal Mode

| Keybinding | Action |
|------------|--------|
| `p` | Paste |

### Visual Mode

| Keybinding | Action |
|------------|--------|
| `<` | Decrease indent (stays in visual mode) |
| `>` | Increase indent (stays in visual mode) |
| `Alt-j` | Move selected text down |
| `Alt-k` | Move selected text up |
| `p` | Paste without yanking replaced text |

### Visual Block Mode

| Keybinding | Action |
|------------|--------|
| `J` | Move selected block down |
| `K` | Move selected block up |
| `Alt-j` | Move selected block down |
| `Alt-k` | Move selected block up |

---

## 🎯 Quick Reference by Category

### Most Used Keybindings

```
Space w      → Save file
Space e      → Toggle file explorer
Space ff     → Quick open / Find files
Space fg     → Search in files
jk           → Exit insert mode
Ctrl-h/j/k/l → Navigate between windows/panes
Ctrl-u/d     → Scroll up/down
```

### Leader Key Groups (with which-key)

```
<leader>f → Find operations
<leader>g → Git operations (reserved)
<leader>c → Code operations (reserved)
<leader>t → Toggle operations (reserved)
```

---

## 🔧 Configuration Details

### VSCode Integration Settings

- **Composite timeout:** 200ms
- **Composite escape:** `jk` → triggers escape
- **Ctrl keys forwarded to Neovim:** h, j, k, l, u, d

### Environment Detection

All keybindings automatically adapt based on whether you're running in:
- **VSCode:** Uses VSCode commands via `vscode.action()`
- **Native Neovim:** Uses standard Neovim/plugin commands

---

## 💡 Tips

1. **Leader key delay:** After pressing `Space`, you have 200ms to complete the combo
2. **Visual mode indent:** Use `<` and `>` repeatedly while staying in visual mode
3. **Window navigation:** Works consistently across VSCode and native Neovim
4. **Quick escape:** `jk` is faster than reaching for `Esc`
5. **Paste in visual mode:** The `p` mapping preserves your clipboard when replacing text

---

## 🎨 Reserved Key Groups (for future customization)

- `<leader>g*` - Git operations
- `<leader>c*` - Code actions
- `<leader>t*` - Toggle operations

---

*Generated from config at: `/Users/ebinchanged/.config/nvim/`*
*Last updated: February 14, 2026*
