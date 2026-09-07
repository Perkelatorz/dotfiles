# Dotfiles scripts (single source of truth)

All user scripts live here. Referenced by Hyprland (autostart, keybinds) and Quickshell.

- `launch-quickshell.sh` – start Quickshell bar (Hyprland exec-once)
- `select-wallpaper.sh` – wallpaper + matugen theming (Super+W, Quick Settings Theme)
- `write-bar-widgets.sh` – persist bar widget toggles (Quickshell)
- `pkgs` – keep the yadm package lists in step with what is installed (Super+Z opens the picker). Also `pkgs drift` / `missing` / `status` / `add PKG` / `baseline` from a terminal.
- `keybind-cheatsheet.sh` – show keybinds in rofi (Super+/)
- `clipboard-rofi.sh` – cliphist+rofi clipboard manager (text/images/all)
- `screenshot-*.sh` – fullscreen, region, last region (Quickshell screenshot widget)
- `_wayland-env.sh` – sourced helper; recovers WAYLAND_DISPLAY when exec'd without env

The executable bit is tracked by git (mode 100755), so a fresh clone gets it
with no bootstrap step. `_compositor.sh` and `_wayland-env.sh` are deliberately
non-executable — they are sourced, not run.
