# Quickshell bar – dependencies

Everything you need for this config to work. Optional items only affect specific widgets (those widgets hide or no-op if the dependency is missing).

---

## Core (required)

| Dependency | Purpose |
|------------|--------|
| **Quickshell** | Bar runtime (Qt 6, Wayland). Build/install from your distro or [quickshell](https://github.com/nicksrandall/quickshell). |
| **Hyprland** | Workspaces, client list, fullscreen detection, window close/focus, power menu, launching apps via `hyprctl dispatch exec`. |
| **Pipewire** | Audio (volume widget, Quick Settings sliders, microphone). Used with **WirePlumber** for `wpctl`. |
| **wl-copy** | Clipboard for screenshots (from `wl-clipboard`). |

---

## Audio

| Dependency | Used by |
|------------|--------|
| **wpctl** | Volume widget (wheel), microphone mute, Settings menu volume/sink list, Quick Settings volume slider and sink name. Usually from **WirePlumber** or **pipewire-wireplumber**. |
| **pavucontrol** | Volume widget click; Quick Settings Audio card and volume gear (configurable: `audioSettingsCommand`). Can be replaced with e.g. `pulsemixer` or `ncpamixer`. |

---

## Screenshots

| Dependency | Used by |
|------------|--------|
| **grim** | Fullscreen and region screenshots. |
| **slurp** | Region selection for “Select region” and “Same as last” (geometry stored in `~/.cache/.../quickshell-last-slurp`). |

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
| **swaylock** or **hyprlock** | Lock (Quick Settings lock button and power menu). Default is **swaylock** with fallback to **hyprlock** in Quick Settings; power menu uses `lockCommand` (default `swaylock`). |

---

## Quick Settings panel

| Dependency | Used by |
|------------|--------|
| **hyprctl** | All card/gear clicks: apps are launched with `hyprctl dispatch exec` so they get the correct Wayland session. |
| **nmcli** | Wi‑Fi card (SSID, signal), VPN card (active VPN name). From **NetworkManager**. |
| **bluetoothctl** | Bluetooth card (On/Off, device count). |
| **nm-connection-editor** | Wi‑Fi and VPN card click (NetworkManager GUI). |
| **blueman-manager** | Bluetooth card click (optional; falls back to `bluetoothctl` in a shell if not installed). |
| **system-config-printer** | Printers card click (CUPS GUI). |
| **nwg-displays** | Brightness gear click (configurable: `displaySettingsCommand`). Can be another display settings app. |
| **df** | Disk card (root filesystem usage). Coreutils. |
| **lpstat** | Printers card (printer and job count). From **CUPS**. |
| **id** | User name in Quick Settings header. Coreutils. |

Quick Settings also uses: **wpctl** (sink name for Audio card), **Pipewire** (volume/mic), **/sys** (battery, backlight), **/proc/uptime** (uptime). Theme card runs `select-wallpaper.sh --material` (see Theming below).

---

## Optional widgets (no extra deps)

- **Battery**: reads `/sys/class/power_supply/BAT*/capacity` and `status` (Linux kernel).
- **Brightness (sysfs)**: reads/writes `/sys/class/backlight/*` (kernel, no extra package).
- **CPU/RAM**: read `/proc/stat` and `/proc/meminfo` (kernel).
- **Clock/calendar**: in-QML only.
- **Workspaces / Client list**: Hyprland only.

---

## Optional (if you use those widgets)

| Dependency | Used by |
|------------|--------|
| **brightnessctl** | Brightness widget and Quick Settings brightness slider when there is no `/sys/class/backlight` (e.g. some desktops or external monitors via DDC). |
| **ip** | IP address widget (from `iproute2`). |
| **nm-connection-editor** | IP widget click (NetworkManager GUI). |
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

Only needed if you run `select-wallpaper.sh` for theme/wallpaper changes. Quick Settings “Theme” card runs this script with `--material`.

---

## Font

- **JetBrainsMono Nerd Font** (or whatever you set in `Colors.qml` / `Colors.qml.tmpl.*` as `fontMain` / `widgetIconFont`) for bar text and icons.

---

## Minimal “must have” set

For the bar to run and do something useful:

- Quickshell  
- Hyprland  
- Pipewire + WirePlumber (`wpctl`)  
- wl-copy  
- grim (+ slurp for region/same-as-last screenshots)  
- playerctl (if you use Now Playing)  
- systemctl + loginctl  
- swaylock or hyprlock (for lock)  
- pavucontrol (or another app for volume click)  

Quick Settings panel additionally benefits from: **nmcli**, **bluetoothctl**, **nm-connection-editor**, **df**, **lpstat** (optional: **blueman-manager**, **system-config-printer**, **nwg-displays**). Everything else is optional or has fallbacks (e.g. battery/brightness hide when no `/sys` data; cards show “N/A” or “No data” when a command is missing).
