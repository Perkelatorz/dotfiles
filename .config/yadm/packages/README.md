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
