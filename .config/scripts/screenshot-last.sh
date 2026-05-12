#!/usr/bin/env bash
# Re-shoot the last slurp region saved by screenshot-region.sh.
set -e
. "$(dirname "$0")/_wayland-env.sh"

C="${XDG_CACHE_HOME:-$HOME/.cache}"
f="$C/quickshell-last-slurp"
[ -f "$f" ] || exit 0
T="$C/quickshell-shot-$$.png"
grim -g "$(cat "$f")" - >"$T" && wl-copy -t image/png <"$T"
rm -f "$T"
