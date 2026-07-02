# shellcheck shell=bash
# Recover WAYLAND_DISPLAY/XDG_RUNTIME_DIR from a running session process.
# Needed when scripts are exec'd via hyprctl/quickshell without env inheritance.
# Source this file: . "$(dirname "$0")/_wayland-env.sh"
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  for _pid in $(pgrep -n kitty 2>/dev/null) \
              $(pgrep -n foot 2>/dev/null) \
              $(pgrep -n Hyprland 2>/dev/null | head -1) \
              $(pgrep -n mango 2>/dev/null | head -1); do
    [ -z "$_pid" ] || [ ! -r "/proc/$_pid/environ" ] && continue
    while IFS= read -r -d '' _line; do
      case "$_line" in
        WAYLAND_DISPLAY=*|XDG_RUNTIME_DIR=*) export "${_line?}" ;;
      esac
    done <"/proc/$_pid/environ" 2>/dev/null
    [ -n "${WAYLAND_DISPLAY:-}" ] && break
  done
  unset _pid _line
fi
