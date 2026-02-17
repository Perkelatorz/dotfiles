#!/usr/bin/env bash
# Run by ScreenshotWidget. If WAYLAND_DISPLAY is unset (e.g. from hyprctl exec), copy from an existing session process.
set -e
if [ -z "${WAYLAND_DISPLAY}" ]; then
  for pid in $(pgrep -n kitty 2>/dev/null) $(pgrep -n foot 2>/dev/null) $(pgrep -n Hyprland 2>/dev/null | head -1) $(pgrep -n mango 2>/dev/null | head -1); do
    [ -z "$pid" ] || [ ! -r "/proc/$pid/environ" ] && continue
    while IFS= read -r -d '' line; do
      case "$line" in WAYLAND_DISPLAY=*|XDG_RUNTIME_DIR=*) export "$line" ;; esac
    done < "/proc/$pid/environ" 2>/dev/null && [ -n "$WAYLAND_DISPLAY" ] && break
  done
fi
C="${XDG_CACHE_HOME:-$HOME/.cache}"
T="$C/quickshell-shot-$$.png"
if command -v wayfreeze &>/dev/null; then
  wayfreeze &
  FREEZE_PID=$!
  sleep 0.1
  g=$(slurp) || { kill "$FREEZE_PID" 2>/dev/null; exit 0; }
  [ -z "$g" ] && { kill "$FREEZE_PID" 2>/dev/null; exit 0; }
  grim -g "$g" - > "$T" && wl-copy -t image/png < "$T"
  echo "$g" > "$C/quickshell-last-slurp"
  kill "$FREEZE_PID" 2>/dev/null
  rm -f "$T"
else
  g=$(slurp) || exit 0
  [ -z "$g" ] && exit 0
  grim -g "$g" - > "$T" && wl-copy -t image/png < "$T"
  echo "$g" > "$C/quickshell-last-slurp"
  rm -f "$T"
fi
