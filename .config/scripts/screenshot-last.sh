#!/usr/bin/env bash
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
f="$C/quickshell-last-slurp"
T="$C/quickshell-shot-$$.png"
[ -f "$f" ] || exit 0
grim -g "$(cat "$f")" - > "$T" && wl-copy -t image/png < "$T"
rm -f "$T"
