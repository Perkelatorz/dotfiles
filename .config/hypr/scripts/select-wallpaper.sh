#!/bin/bash

# ---
# A HYBRID script that uses Pywal for instant theming and then updates WPGtk.
# This script is the primary driver for changing themes.
# ---

# --- CONFIGURATION ---
WALLPAPER_DIR=$HOME/Pictures/
WAYBAR_DIR="$HOME/.config/waybar"

# --- SCRIPT LOGIC ---

# 1. Get a list of all wallpapers and let the user select one
# (Includes the "Random" option)
WALLPAPER_LIST=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.gif' \))
if [ -z "$WALLPAPER_LIST" ]; then
  echo "No images found in $WALLPAPER_DIR. Exiting."
  exit 1
fi
SELECTION=$( (
  echo "🎲 Random"
  echo "$WALLPAPER_LIST"
) | rofi -dmenu -i -p "Select Wallpaper")

# 2. Handle the user's selection
if [ -z "$SELECTION" ]; then
  echo "No wallpaper selected. Exiting."
  exit 0
elif [ "$SELECTION" = "🎲 Random" ]; then
  FINAL_WALLPAPER=$(echo "$WALLPAPER_LIST" | shuf -n 1)
else
  FINAL_WALLPAPER="$SELECTION"
fi

# --- THEME GENERATION & APPLICATION ---

echo "--- Starting Theme Update ---"

# Step A: Run Pywal for instant Terminal/Waybar theme
echo "🎨 [Pywal] Generating fast theme..."
wal -q -i "$FINAL_WALLPAPER"

# Step B: Set the wallpaper using your preferred tool
echo "🖼️ [swww] Setting wallpaper..."
awww img "$FINAL_WALLPAPER" --transition-type any

# Step C: Update Waybar's CSS from Pywal's cache
echo "🎨 [Waybar] Updating Waybar CSS..."
source "$HOME/.cache/wal/colors.sh"
(
  cat <<EOF
/* Pywal colors for Waybar */
@define-color background ${background}; @define-color foreground ${foreground}; @define-color cursor ${cursor};
@define-color color0 ${color0}; @define-color color1 ${color1}; @define-color color2 ${color2}; @define-color color3 ${color3};
@define-color color4 ${color4}; @define-color color5 ${color5}; @define-color color6 ${color6}; @define-color color7 ${color7};
@define-color color8 ${color8}; @define-color color9 ${color9}; @define-color color10 ${color10}; @define-color color11 ${color11};
@define-color color12 ${color12}; @define-color color13 ${color13}; @define-color color14 ${color14}; @define-color color15 ${color15};
EOF
) | sed "s/'//g" >"$WAYBAR_DIR/pywal-colors.css"
if ! pgrep -x waybar >/dev/null; then
  pkill -SIGUSR2 waybar
  waybar &
fi

# Step D: Update WPGtk with the same wallpaper
# This will generate colors and apply the theme to GTK and other apps.
echo "🎨 [WPGtk] Syncing theme..."
wpg -s "$FINAL_WALLPAPER"

echo "✅ Theme updated successfully!"
