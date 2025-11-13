#!/bin/bash

# Check if a wallpaper was provided
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/wallpaper"
  exit 1
fi

WALLPAPER="$1"

# 1. Generate color scheme with Pywal
#    The '-n' flag skips setting the wallpaper, as swww will handle it.
#    The '-q' flag makes it run quietly.
echo "Generating color scheme with Pywal..."
wal -i "$WALLPAPER" -n -q

# 2. Set the wallpaper with swww
echo "Setting wallpaper with swww..."
awww img "$WALLPAPER" --transition-type any --transition-fps 60

echo "Done."
