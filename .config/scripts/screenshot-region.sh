#!/usr/bin/env bash
# Region screenshot via slurp+grim. Saves region to cache for screenshot-last.sh.
# Run by ScreenshotWidget (Quickshell).
set -e
. "$(dirname "$0")/_wayland-env.sh"

C="${XDG_CACHE_HOME:-$HOME/.cache}"
T="$C/quickshell-shot-$$.png"
mkdir -p "$C"

shoot() {
  local g="$1"
  grim -g "$g" - >"$T" && wl-copy -t image/png <"$T"
  echo "$g" >"$C/quickshell-last-slurp"
  rm -f "$T"
}

if command -v wayfreeze &>/dev/null; then
  wayfreeze &
  FREEZE_PID=$!
  trap 'kill "$FREEZE_PID" 2>/dev/null || true' EXIT
  sleep 0.1
  g=$(slurp) || exit 0
  [ -z "$g" ] && exit 0
  shoot "$g"
else
  g=$(slurp) || exit 0
  [ -z "$g" ] && exit 0
  shoot "$g"
fi
