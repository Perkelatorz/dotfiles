#!/usr/bin/env bash
# Capture focused monitor (Hyprland). Set OUTPUT=name to override, OUTPUT=all for full span.
set -e
. "$(dirname "$0")/_wayland-env.sh"

if [ "${OUTPUT:-}" = "all" ]; then
  grim - | wl-copy -t image/png
elif [ -n "${OUTPUT:-}" ]; then
  grim -o "$OUTPUT" - | wl-copy -t image/png
else
  out=""
  if command -v hyprctl &>/dev/null && command -v jq &>/dev/null && pgrep -x Hyprland &>/dev/null; then
    out=$(hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused == true) | .name' | head -1)
  fi
  if [ -n "$out" ]; then
    grim -o "$out" - | wl-copy -t image/png
  else
    grim - | wl-copy -t image/png
  fi
fi
