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

## 6. Summary

- **One config:** `~/.config/matugen/config.toml` — add a `[templates.<name>]` block for every app you want.
- **One run:** `select-wallpaper.sh` runs matugen once; matugen fills all configured templates.
- **Per-app:** Include the generated file in the app’s config and, if possible, add a reload step in the script so the theme applies immediately.

That way, the same theme flows from one wallpaper run into as many apps as you configure.
