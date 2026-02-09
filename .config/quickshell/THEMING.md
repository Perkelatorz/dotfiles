# Making the theme work across as many apps as possible

This config uses **matugen** to generate a Material You palette from your wallpaper. One run of `select-wallpaper.sh` updates the wallpaper and runs matugen; matugen then fills **every template** defined in `~/.config/matugen/config.toml`. So the way to get the theme into more apps is:

1. **Add a template for each app** you use in `~/.config/matugen/config.toml`.
2. **Point each template** at a file from [matugen-themes](https://github.com/InioX/matugen-themes) (or your own) and set the output path to where that app reads its colors.
3. **Wire your app config** to include/source that generated file (see matugen-themes README per app).
4. **Reload the app** after a theme change — `select-wallpaper.sh` already reloads several apps; more can be added (see below).

---

## 1. Where the theme is defined

- **Single place:** `~/.config/matugen/config.toml`. You can use `~` in paths; `select-wallpaper.sh` expands it to your home directory before calling matugen (matugen does not expand `~` itself).
- **Templates repo:** [InioX/matugen-themes](https://github.com/InioX/matugen-themes) — clone it and use its `templates/` files as `input_path`.
- **This repo:** We use a **custom** Quickshell template: `Colors.qml.tmpl` (and `.material` / `.rainbow`). Your matugen config must include a template whose **output** is `~/.config/quickshell/Colors.qml` and whose **input** is `~/.config/quickshell/Colors.qml.tmpl` (the script copies the style-specific tmpl there before running matugen). See `matugen-config-example.toml` in this folder.

---

## 2. Quick setup for many apps

```bash
# Clone official templates (once)
git clone https://github.com/InioX/matugen-themes.git ~/.config/matugen-themes
```

Then merge the `[templates]` from `matugen-config-example.toml` in this repo into your `~/.config/matugen/config.toml`, and set every `input_path` to use `~/.config/matugen-themes/templates/...` (see the example). Enable only the apps you use by uncommenting the corresponding `[templates.xxx]` blocks.

---

## 3. Apps that support matugen (via matugen-themes)

| App | Template file | Output path (typical) | Reload after theme? |
|-----|----------------|------------------------|----------------------|
| **Quickshell** | (local) `Colors.qml.tmpl` | `~/.config/quickshell/Colors.qml` | ✅ script restarts quickshell |
| **Hyprland** | `hyprland-colors.conf` | `~/.config/hypr/matugen-colors.conf` | ✅ script runs `hyprctl reload` |
| **Kitty** | `kitty-colors.conf` | `~/.config/kitty/themes/Matugen.conf` or `matugen-colors.conf` | ✅ script sends SIGUSR1 to kitty |
| **Dunst** | `dunstrc-colors` | `~/.config/dunst/dunstrc` (include in main dunstrc) | ✅ script sends SIGUSR2 to dunst |
| **Rofi** | `rofi-colors.rasi` | `~/.config/rofi/colors.rasi` | ✅ add reload in script (optional) |
| **Fuzzel** | `fuzzel.ini` | `~/.config/fuzzel/colors.ini` | No live reload (next launch) |
| **GTK 3/4** | `gtk-colors.css` | `~/.config/gtk-3.0/colors.css`, `~/.config/gtk-4.0/colors.css` | ✅ gsettings or restart apps |
| *Thunar, Nautilus, etc.* | *(use GTK 3/4 above)* | — | Same as GTK; no separate template |
| **Alacritty** | `alacritty.toml` | `~/.config/alacritty/colors.toml` | No (new windows) |
| **WezTerm** | `wezterm_theme.toml` | `~/.config/wezterm/colors/matugen_theme.toml` | Touch wezterm.lua or new tab |
| **Foot** | (use alacritty or custom) | — | — |
| **Btop** | `btop.theme` | `~/.config/btop/themes/matugen.theme` | ✅ script can pkill -USR2 btop |
| **Cava** | `cava-colors.ini` | `~/.config/cava/themes/matugen` | pkill -USR1 cava |
| **Neovim** | `nvim-colors.vim` | `~/.config/nvim/colors/matugen.vim` | SIGUSR1 or `:colorscheme matugen` |
| **Helix** | `helix.toml` | `~/.config/helix/themes/matugen.toml` | New windows |
| **Tmux** | `tmux-colors.conf` | `~/.config/tmux/generated.conf` | `tmux source-file ...` |
| **Zathura** | `zathura-colors` | `~/.config/zathura/zathurarc` | New documents |
| **Starship** | `starship-colors.toml` | `~/.config/starship.toml` (or include) | New shells |
| **Qt (qt5ct/qt6ct)** | `qtct-colors.conf` | `~/.config/qt5ct/colors/matugen.conf` etc. | Restart Qt apps |
| **Kvantum** | `kvantum-colors.kvconfig` + `.svg` | `~/.config/Kvantum/matugen/` | Kvantum manager |
| **Wlogout** | (use colors.css) | `~/.config/wlogout/colors.css` | Next open |
| **SwayNC** | `colors.css` | `~/.config/swaync/colors.css` | swaync-client -rs |
| **Vivaldi** | `vivaldi.css` | Custom UI folder | Vivaldi reload |
| **Spotify (Spicetify)** | `spicetify.ini` | Spicetify theme dir | spicetify watch |
| **Firefox (Pywalfox)** | `pywalfox-colors.json` | `~/.cache/wal/colors.json` | pywalfox update |
| **Zed** | `zed-colors.json` | `~/.config/zed/themes/matugen.json` | Settings → theme |
| **Yazi** | `yazi-theme.toml` | `~/.config/yazi/theme.toml` | New instances |

For each app, see the [matugen-themes README](https://github.com/InioX/matugen-themes) for the exact `input_path`, `output_path`, and how to include the generated file in the app’s config.

---

## 4. What the script already does

- Runs **matugen** with your wallpaper and `--config ~/.config/matugen/config.toml`, so **all** templates in that config are generated.
- Restarts **Quickshell** so the bar uses the new `Colors.qml`.
- Reloads **Hyprland** if `~/.config/hypr/matugen-colors.conf` exists.
- Reloads **Kitty** (SIGUSR1) if `~/.config/kitty/matugen-colors.conf` or `~/.config/kitty/themes/Matugen.conf` exists.
- Reloads **Dunst** (SIGUSR2) if dunstrc contains "matugen".
- Reloads **Btop** (SIGUSR2) if matugen theme exists and btop is running; touches **WezTerm** config when matugen theme exists; runs **gsettings** for GTK; **Rofi** uses new colors on next open.
- You can extend the “OTHER APP RELOADS” section in `select-wallpaper.sh` to add more apps (e.g. Cava, Neovim, SwayNC).

---

## 5. Hyprland and high-contrast text

The script appends high-contrast text variables to `~/.config/hypr/matugen-colors.conf` when `GENERATE_HIGH_CONTRAST_TEXT=true`. So matugen should write Hyprland colors to that file (not `colors.conf`), and your `hyprland.conf` should source it:

```conf
source = ~/.config/hypr/matugen-colors.conf
```

---

## 6. GTK apps (Thunar, Nautilus, and most GUI apps)

Matugen already writes `~/.config/gtk-3.0/colors.css` and `~/.config/gtk-4.0/colors.css`. For GTK to **use** them:

1. **Base theme** — Use a theme that supports custom colors. Recommended: **Dark** `adw-gtk3-dark`, **Light** `adw-gtk3`. Install: `adw-gtk3` (Arch).
2. **Make GTK load matugen colors** — `select-wallpaper.sh` creates `~/.config/gtk-4.0/gtk.css` and `~/.config/gtk-3.0/gtk.css` (if missing) with `@import "colors.css";`. Run the wallpaper script once so it can add `gtk.css`.
3. **Set the theme and icons in your session** — In `~/.config/hypr/env.conf` set `env = GTK_THEME,adw-gtk3-dark` and `env = GTK_ICON_THEME,Papirus-Dark` (or another icon theme like `Adw-icon-theme`). New GTK apps inherit these. **Restart already-open GTK apps** (e.g. Thunar, Firefox) so they pick up new matugen colors and the icon theme; the script cannot reload running apps.
4. The script rewrites `gtk.css` every run (so its mtime updates), runs `gsettings set` for gtk-theme and icon-theme, and touches the CSS files so the next time you open a GTK app it sees the updated palette.

---

## 7. Qt apps (qt5ct, qt6ct, Kvantum)

**Qt5 (qt5ct):** Matugen writes `~/.config/qt5ct/colors/matugen.conf`. Set `QT_QPA_PLATFORMTHEME=qt5ct` in `~/.config/hypr/env.conf`, then run `qt5ct` → Appearance → Color scheme → **matugen** → Apply. Qt5 apps use the matugen palette; restart apps after a theme change.

**Qt6 (qt6ct):** Matugen now writes `~/.config/qt6ct/colors/matugen.conf` (same template as Qt5). Set `QT_QPA_PLATFORMTHEME=qt6ct` in `~/.config/hypr/env.conf` so Qt6 apps use qt6ct, then run `qt6ct` → Appearance → Color scheme → **matugen** → Apply. Install `qt6ct` if needed (e.g. Arch: `qt6ct`). Note: if you use both Qt5 and Qt6 apps, you can only set one platform theme globally; use qt5ct for Qt5 and qt6ct for Qt6 depending on which toolkit your apps use, or use Kvantum for both.

**Kvantum:** For a unified Qt5+Qt6 look, matugen-themes has Kvantum templates. Add `[templates.kvantum_kvconfig]` and `[templates.kvantum_svg]` to your matugen config (see matugen-themes README), then in Kvantum Manager set the theme to the generated one and set `QT_QPA_PLATFORMTHEME=kvantum`.

---

## 8. Summary

- **One config:** `~/.config/matugen/config.toml` — add a `[templates.<name>]` block for every app you want.
- **One run:** `select-wallpaper.sh` runs matugen once; matugen fills all configured templates.
- **GTK:** Use theme `adw-gtk3-dark` (or `adw-gtk3`); script creates `gtk.css` so GTK loads matugen `colors.css`.
- **Qt5:** Set qt5ct color scheme to **matugen**; **Qt6:** qt6ct template added — set qt6ct color scheme to **matugen**; Kvantum optional for both.
- **Per-app:** Include the generated file in the app’s config and, if possible, add a reload step in the script so the theme applies immediately.

That way, the same theme flows from one wallpaper run into as many apps as you configure.
