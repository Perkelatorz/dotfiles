# Quickshell workspace bar

A simple top bar that shows Hyprland workspaces with **multi-monitor support**: each screen gets its own bar showing only the workspaces on that monitor.

## Requirements

- **Quickshell** (e.g. `pacman -S quickshell` on Arch)
- **Hyprland** as the Wayland compositor (Quickshell talks to it via Hyprland IPC)

## Run

From this directory:

```bash
quickshell
```

Or point Quickshell at this config, e.g.:

```bash
quickshell -C ~/.config/quickshell
```

## Behavior

- One bar per monitor, anchored to the top (wlr-layer-shell top layer).
- Each bar lists only the workspaces on that monitor.
- **Focused** workspace: blue pill; **active** (on this monitor but not focused): dark gray; **inactive**: darker.
- Click a workspace to switch to it (`workspace.activate()`).

## Bar features

- **Left:** Workspace dots (1–x per screen); solid = occupied, empty = empty; highlighted = current.
- **Center:** Open windows on the current workspace (with app icon); click to focus; focused window has distinct background.
- **Right:** System tray (StatusNotifierItem); left-click = activate, right-click or menu-only items = context menu; scroll on icon (e.g. volume). Requires `//@ pragma UseQApplication` for platform menus.

Theme colors are in the `theme` QtObject at the top of `shell.qml` so you can change the look in one place.

## Additional services / docs

- [Additional services (e.g. System Tray) – DeepWiki](https://deepwiki.com/quickshell-mirror/quickshell/7.3-additional-services)
- [Quickshell Types – SystemTray](https://quickshell.org/docs/types/Quickshell.Services.SystemTray/SystemTray/) and [SystemTrayItem](https://quickshell.org/docs/types/Quickshell.Services.SystemTray/SystemTrayItem/)

## LSP (optional)

For QML/Quickshell editing, create an empty `.qmlls.ini` next to `shell.qml`; Quickshell can generate it. Add `.qmlls.ini` to your `.gitignore` if you use git.
