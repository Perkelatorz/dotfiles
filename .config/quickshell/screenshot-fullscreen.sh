#!/usr/bin/env bash
# Optional: set OUTPUT=outputname for single-output; unset = whole session
set -e
if [ -z "${WAYLAND_DISPLAY}" ]; then
  for pid in $(pgrep -n kitty 2>/dev/null) $(pgrep -n foot 2>/dev/null) $(pgrep -n Hyprland 2>/dev/null | head -1); do
    [ -z "$pid" ] || [ ! -r "/proc/$pid/environ" ] && continue
    while IFS= read -r -d '' line; do
      case "$line" in WAYLAND_DISPLAY=*|XDG_RUNTIME_DIR=*) export "$line" ;; esac
    done < "/proc/$pid/environ" 2>/dev/null && [ -n "$WAYLAND_DISPLAY" ] && break
  done
fi
if [ -n "$OUTPUT" ]; then
  grim -o "$OUTPUT" - | wl-copy -t image/png
else
  grim - | wl-copy -t image/png
fi
