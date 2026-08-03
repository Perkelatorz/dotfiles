#!/usr/bin/env bash
# Wake every display. No-op when they are already on, so it's safe to fire from
# hypridle's on-resume on every input event.
set -euo pipefail

# shellcheck source=/dev/null
. "$(dirname "$0")/_compositor.sh"

case "$COMPOSITOR" in
  hyprland)
    hyprctl dispatch dpms on
    ;;
  mango)
    compositor_monitors | while IFS= read -r mon; do
      [ -n "$mon" ] && mmsg dispatch "wakeup_monitor,$mon" >/dev/null
    done
    ;;
  *)
    echo "screen-on: unsupported compositor '${COMPOSITOR}'" >&2
    exit 1
    ;;
esac
