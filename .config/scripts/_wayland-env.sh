# shellcheck shell=bash
# Recover WAYLAND_DISPLAY/XDG_RUNTIME_DIR plus the compositor IPC handle from a
# running session process. Needed when scripts are exec'd via hyprctl/mmsg/
# quickshell without env inheritance.
# Source this file: . "$(dirname "$0")/_wayland-env.sh"
#
# Only ever read this from a compositor CHILD (a terminal), never from the
# compositor process itself: /proc/<pid>/environ is a snapshot taken at exec,
# and both Hyprland and mango setenv() their instance signature (and mango its
# XDG_CURRENT_DESKTOP) *after* that point. Reading mango's own environ returns
# whatever the display manager happened to export — i.e. stale or absent.
if [ -z "${WAYLAND_DISPLAY:-}" ] ||
   { [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -z "${MANGO_INSTANCE_SIGNATURE:-}" ]; }; then
  for _pid in $(pgrep -n kitty 2>/dev/null) \
              $(pgrep -n foot 2>/dev/null) \
              $(pgrep -n alacritty 2>/dev/null); do
    [ -z "$_pid" ] || [ ! -r "/proc/$_pid/environ" ] && continue
    while IFS= read -r -d '' _line; do
      case "$_line" in
        WAYLAND_DISPLAY=*|XDG_RUNTIME_DIR=*|\
        HYPRLAND_INSTANCE_SIGNATURE=*|MANGO_INSTANCE_SIGNATURE=*) export "${_line?}" ;;
      esac
    done <"/proc/$_pid/environ" 2>/dev/null
    [ -n "${WAYLAND_DISPLAY:-}" ] && break
  done
  unset _pid _line
fi

# Last resort for mango: the socket is named after the compositor pid, so it can
# be reconstructed without any process environment at all.
if [ -z "${MANGO_INSTANCE_SIGNATURE:-}" ] || [ ! -S "${MANGO_INSTANCE_SIGNATURE:-}" ]; then
  _mpid=$(pgrep -x mango 2>/dev/null | head -1)
  if [ -n "$_mpid" ]; then
    _sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/mango-${_mpid}.sock"
    [ -S "$_sock" ] && export MANGO_INSTANCE_SIGNATURE="$_sock"
    unset _sock
  fi
  unset _mpid
fi
