# Package Lists

This directory contains package list files used by the bootstrap script.

## File Naming Convention

- `*.pkgs` - Pacman (official repository) packages
- `*.aur` - AUR (Arch User Repository) packages

## Core Packages

- `core.pkgs` - Essential pacman packages (installed automatically)
- `core.aur` - Essential AUR packages (installed automatically)

## Profile Packages

- `profile_*.pkgs` - Profile-specific pacman packages (user selects via fzf)
- `profile_*.aur` - Profile-specific AUR packages (user selects via fzf)

## File Format

Each file contains one package name per line. Empty lines and lines starting with `#` are ignored.

Example:
```
# This is a comment
package-name
another-package
# another-comment
```

## Adding New Package Lists

1. Create a new file with `.pkgs` or `.aur` extension
2. Add package names, one per line
3. The bootstrap script will automatically detect and offer it for selection (if not named `core.*`)

## Neovim

Core **pacman** packages for Neovim (git, curl, build toolchain, `tree-sitter` CLI, `neovim`, …) are in **`core.pkgs`**. After core installs, **`bootstrap`** runs a short headless **`nvim`** pass so **vim.pack** pulls plugins. Mason LSP/tools finish when you open **`:Mason`** in Neovim.

**Claude Code CLI** — after core packages, **`install_claude_code_cli`** downloads and runs Anthropic’s **`https://claude.ai/install.sh`** (same as `curl -fsSL … | bash`). Skip with **`CLAUDE_CODE_SKIP=1 yadm bootstrap`**. Ensure **`~/.local/bin`** is on your **`PATH`** (typical for the installed `claude` binary).

**Pacman:** by default the script runs **`pacman -Sy`** then installs packages (Arch documents risks of syncing without upgrading). For a full upgrade during bootstrap use **`BOOTSTRAP_FULL_SYSTEM_UPGRADE=1 yadm bootstrap`** (runs **`pacman -Syu`** after sync).

**Default browser** — **`firefox`** and **`xdg-utils`** are in **`core.pkgs`**. After core installs, **`setup_default_browser_firefox`** runs **`xdg-mime default …`** for **`x-scheme-handler/http`** and **`https`**. **`BROWSER=firefox`** is also set in **`~/.config/environment.d/browser.conf`** (systemd user session) and **`~/.config/zsh/.zprofile`** (login shells). Re-login to apply **`environment.d`** everywhere; or run **`systemctl --user import-environment BROWSER`** after editing.
