# Quickshell bar – dependencies

Everything you need for this config to work. Optional items only affect specific widgets (those widgets hide or no-op if the dependency is missing).

---

## Core (required)

| Dependency | Purpose |
|------------|--------|
| **Quickshell** | Bar runtime (Qt 6, Wayland). Build/install from your distro or [quickshell](https://github.com/nicksrandall/quickshell). |
| **Hyprland** | Workspaces, client list, fullscreen detection, window close/focus, power menu lock. Uses `hyprctl`. |
| **Pipewire** | Audio (volume widget default sink/source, microphone). Used with **WirePlumber** for `wpctl`. |
| **wl-copy** | Clipboard for screenshots (from `wl-clipboard`). |

---

## Audio

| Dependency | Used by |
|------------|--------|
| **wpctl** | Volume widget (wheel), microphone mute, settings menu volume/sink list. Usually from **WirePlumber** or **pipewire-wireplumber**. |
| **pavucontrol** | Volume widget click (configurable: `volumeControlCommand`). Can be replaced with e.g. `pulsemixer` or `ncpamixer`. |

---

## Screenshots

| Dependency | Used by |
|------------|--------|
| **grim** | Fullscreen and region screenshots. |
| **slurp** | Region selection for “Select region” and “Same as last” (geometry stored in `~/.cache/quickshell-last-slurp`). |

---

## Media (Now Playing)

| Dependency | Used by |
|------------|--------|
| **playerctl** | Now Playing widget and mini player: metadata, play/pause/prev/next, list players (MPRIS). |

---

## System / power

| Dependency | Used by |
|------------|--------|
| **systemctl** | Power menu: suspend, hibernate, reboot, shutdown (configurable in `PowerMenuContent.qml`). |
| **loginctl** | Power menu: logout. |
| **hyprlock** | Power menu: Lock (configurable: `lockCommand`). |

---

## Optional widgets (no extra deps)

- **Battery**: reads `/sys/class/power_supply/BAT*/capacity` and `status` (Linux kernel).
- **Brightness**: reads/writes `/sys/class/backlight/*` (kernel, no extra package).
- **CPU/RAM**: read `/proc/stat` and `/proc/meminfo` (kernel).
- **Clock/calendar**: in-QML only, no external command.
- **Workspaces / Client list**: Hyprland only.

---

## Optional (if you use those widgets)

| Dependency | Used by |
|------------|--------|
| **ip** | IP address widget (from `iproute2`). |
| **nm-connection-editor** | IP widget click (NetworkManager GUI). |
| **nmcli** | Network widget only (if re-enabled); not used by current bar. |
| **setxkbmap** | Keyboard layout widget (current layout). |
| **btop** (or **htop**) | CPU/RAM widget click (`systemMonitorCommand`, default: `kitty -e btop`). |
| **kitty** | Default terminal for “click to open btop”; override `systemMonitorCommand` if you use another terminal. |

---

## Theming (select-wallpaper.sh)

| Dependency | Purpose |
|------------|--------|
| **matugen** | Generate `Colors.qml` and palette from wallpaper. |
| **rofi** | Style picker UI in the wallpaper script. |
| **awww** | Image viewer in the wallpaper script. |

(Only needed if you run `select-wallpaper.sh` for theme/wallpaper changes.)

---

## Font

- **JetBrainsMono Nerd Font** (or whatever you set in `Colors.qml` / `Colors.qml.tmpl.*` as `fontMain` / `widgetIconFont`) for bar text and icons.

---

## Minimal “must have” set

For the bar to run and do something useful:

- Quickshell  
- Hyprland  
- Pipewire + WirePlumber (so `wpctl` exists)  
- wl-copy  
- grim (+ slurp for region/same-as-last screenshots)  
- playerctl (if you use Now Playing)  
- systemctl + loginctl + hyprlock (for power menu)  
- pavucontrol (or another app for volume click)

Everything else is either optional or has fallbacks (e.g. battery/brightness hide when no `/sys` data).
