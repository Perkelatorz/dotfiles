# Quickshell bar – dependencies

Everything you need for this config to work. Optional items only affect specific widgets (those widgets hide or no-op if the dependency is missing).

---

## Core (required)

| Dependency | Purpose |
|------------|--------|
| **Quickshell** | Bar runtime (Qt 6, Wayland). Build/install from your distro or [quickshell](https://github.com/nicksrandall/quickshell). |
| **Hyprland** or **MangoWC** | Workspace/tag bar and client list. The bar detects the current compositor via `XDG_CURRENT_DESKTOP` and only runs code for that tiler (Hyprland: `hyprctl`, `Quickshell.Hyprland`; MangoWC: `mmsg`, `Quickshell.Wayland` ToplevelManager). |
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
| **wayfreeze** (AUR: **wayfreeze-git**) | Freezes the screen during region selection so the slurp overlay is not captured. Falls back to plain grim+slurp if not installed. |

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
- **Workspaces / Client list**: **Hyprland** – workspace row with per-workspace app icons, center client list, overview panel. **MangoWC** – tag row (dots, click to switch), center client list from ToplevelManager, layout label, fullscreen hides bar. Each compositor’s features only run when that compositor is current (periodic re-check of `XDG_CURRENT_DESKTOP`).
- **Workspace overview** (Hyprland only, keyboard-only): Press a key that runs `~/.config/scripts/open-workspace-overview.sh` to see all workspaces and their windows (no bar button). Example: `bind = $mainMod, W, exec, ~/.config/scripts/open-workspace-overview.sh`
- **MangoWC**: Requires `mmsg` in PATH. Bar shows tags, layout name (tile, scroller, etc.), and hides when a window is fullscreen (`mmsg -g -m`).

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

## Theming (select-wallpaper.sh + GTK/Qt)

All of these are in **yadm** `packages/core.pkgs` or `packages/core.aur` (see `~/.config/yadm/packages/`). Clone matugen-themes separately: `git clone https://github.com/InioX/matugen-themes.git ~/.config/matugen-themes`.

| Dependency | Purpose |
|------------|--------|
| **matugen** | Generate `Colors.qml`, Hyprland/GTK/Qt/Rofi/Kitty/etc. from wallpaper. |
| **rofi** | Style and wallpaper picker UI in the script. |
| **awww** (AUR: **awww-git**) | Wayland wallpaper daemon; script uses it to set the image. |
| **libnotify** | `notify-send` for “Wallpaper Changed” and errors. |
| **adw-gtk3** (AUR: **adw-gtk3-git**) | GTK base theme so matugen `colors.css` is used (set `GTK_THEME=adw-gtk3-dark` in env). |
| **imagemagick** | Optional: pywal-style preprocessing when `PREPROCESS_FOR_PYWAL=true`. |
| **qt5ct** / **qt6ct** | Qt theme config; pick “matugen” color scheme so Qt apps use the palette. |
| **kvantum** | Optional: unified Qt5+Qt6 theming with matugen Kvantum templates. |
| **gsettings** | From **glib2** (usually present); script uses it to nudge GTK theme after a run. |

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
