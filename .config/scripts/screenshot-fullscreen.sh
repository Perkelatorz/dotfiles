#!/usr/bin/env bash
# Capture current/focused monitor only. Set OUTPUT=name to override, or OUTPUT=all for full span.
set -e
if [ -z "${WAYLAND_DISPLAY}" ]; then
  for pid in $(pgrep -n kitty 2>/dev/null) $(pgrep -n foot 2>/dev/null) $(pgrep -n Hyprland 2>/dev/null | head -1); do
    [ -z "$pid" ] || [ ! -r "/proc/$pid/environ" ] && continue
    while IFS= read -r -d '' line; do
      case "$line" in WAYLAND_DISPLAY=*|XDG_RUNTIME_DIR=*) export "$line" ;; esac
    done < "/proc/$pid/environ" 2>/dev/null && [ -n "$WAYLAND_DISPLAY" ] && break
  done
fi
if [ "$OUTPUT" = "all" ]; then
  grim - | wl-copy -t image/png
elif [ -n "$OUTPUT" ]; then
  grim -o "$OUTPUT" - | wl-copy -t image/png
else
  # Use focused monitor (Hyprland)
  out=""
  if command -v hyprctl &>/dev/null && command -v jq &>/dev/null; then
    out=$(hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused == true) | .name' | head -1)
  fi
  if [ -n "$out" ]; then
    grim -o "$out" - | wl-copy -t image/png
  else
    grim - | wl-copy -t image/png
  fi
fi
