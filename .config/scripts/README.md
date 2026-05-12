# Dotfiles scripts (single source of truth)

All user scripts live here. Referenced by Hyprland (autostart, keybinds) and Quickshell.

- `launch-quickshell.sh` – start Quickshell bar (Hyprland exec-once)
- `select-wallpaper.sh` – wallpaper + matugen theming (Super+W, Quick Settings Theme)
- `write-bar-widgets.sh` – persist bar widget toggles (Quickshell)
- `add-package.sh` – add installed packages to yadm lists (Super+Z)
- `hyprkeys.sh` – show keybinds in rofi (Super+/)
- `clipboard-rofi.sh` – cliphist+rofi clipboard manager (text/images/all)
- `open-workspace-overview.sh` – open Quickshell workspace overview
- `screenshot-*.sh` – fullscreen, region, last region (Quickshell screenshot widget)
- `_wayland-env.sh` – sourced helper; recovers WAYLAND_DISPLAY when exec'd without env

Bootstrap makes all `*.sh` here executable after clone.
