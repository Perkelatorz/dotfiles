# Cursor CLI with Neovim

Use **Cursor’s AI agent** from Neovim via the Cursor CLI instead of the Cursor editor.

## 1. Install Cursor CLI

**macOS / Linux / WSL:**

```bash
curl https://cursor.com/install -fsSL | bash
```

**Windows (PowerShell):**

```powershell
irm 'https://cursor.com/install?win32=true' | iex
```

Restart your shell, then check:

```bash
agent --version
```

You must be signed in to Cursor (e.g. in the Cursor app or at [cursor.com](https://cursor.com)) so the CLI can use your account.

## 2. Neovim integration (already in this config)

- **Plugin:** `cursor-agent.nvim` (wraps the CLI in a terminal inside Neovim).
- **Dependency:** `folke/snacks.nvim` (terminal + notifications). Lazy will install it.

### Keybindings

| Key            | Action                          |
|----------------|----------------------------------|
| `<leader>aj`   | Cursor Agent at **project root** |
| `<leader>al`   | Cursor Agent in **current dir**  |
| `<leader>at`   | List / resume **sessions**       |

### Commands

```vim
:CursorAgent              " same as open_cwd
:CursorAgent open_cwd     " start in current file’s directory
:CursorAgent open_root    " start at git/project root
:CursorAgent session_list " list and resume sessions
```

### In the Agent terminal

- **Submit:** `<Ctrl+Enter>` or `<Ctrl+/>` (see help with `??`).
- **Attach current file:** `<Ctrl+Shift+F>`.
- **Attach all buffers:** `<Ctrl+Shift+A>`.
- **Hide terminal:** `q` or `<Ctrl+W>n` in normal mode.

## 3. Using the CLI outside Neovim

```bash
# Interactive
agent

# With an initial prompt
agent "refactor the auth module to use JWT"

# Non-interactive (e.g. scripts)
agent -p "find and fix performance issues" --model "gpt-5.2"
```

## 4. Summary

- **Cursor IDE:** full editor + AI (you’re not using this for editing).
- **Cursor CLI + Neovim:** you edit in Neovim and run Cursor Agent in a terminal (inside or outside Neovim) for tasks, refactors, and reviews.

After installing the CLI and restarting Neovim, `<leader>aj` or `<leader>al` should open the Cursor Agent terminal.
