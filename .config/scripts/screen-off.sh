#!/usr/bin/env bash
# Blank every display. Wakes on mouse/keyboard via the 5s wake-only hypridle
# listener (see hypr/hypridle.conf and mango/idle.conf).
#
# Bound to SUPER+SHIFT+S on both compositors, and used as hypridle's
# on-timeout action.
set -euo pipefail

# shellcheck source=/dev/null
. "$(dirname "$0")/_compositor.sh"

case "$COMPOSITOR" in
  hyprland)
    hyprctl dispatch dpms off
    ;;
  mango)
    # mango's sleep_monitor takes a single monitor spec, so fan it out.
    compositor_monitors | while IFS= read -r mon; do
      [ -n "$mon" ] && mmsg dispatch "sleep_monitor,$mon" >/dev/null
    done
    ;;
  *)
    echo "screen-off: unsupported compositor '${COMPOSITOR}'" >&2
    exit 1
    ;;
esac
