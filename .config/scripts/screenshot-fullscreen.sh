#!/usr/bin/env bash
# Capture the focused monitor. Set OUTPUT=name to override, OUTPUT=all for the
# full span. Falls back to the full span if the focused output can't be read.
set -e
. "$(dirname "$0")/_compositor.sh"

if [ "${OUTPUT:-}" = "all" ]; then
  grim - | wl-copy -t image/png
elif [ -n "${OUTPUT:-}" ]; then
  grim -o "$OUTPUT" - | wl-copy -t image/png
else
  out=""
  if command -v jq &>/dev/null; then
    out=$(compositor_focused_monitor 2>/dev/null || true)
  fi
  if [ -n "$out" ]; then
    grim -o "$out" - | wl-copy -t image/png
  else
    grim - | wl-copy -t image/png
  fi
fi
