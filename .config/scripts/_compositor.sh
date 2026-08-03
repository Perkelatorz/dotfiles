# shellcheck shell=bash
# Detect which compositor is driving this session and expose it as $COMPOSITOR
# ("hyprland", "mango", or "other"). Source this file:
#   . "$(dirname "$0")/_compositor.sh"
#
# Also pulls in _wayland-env.sh, so sourcing this alone is enough to get
# WAYLAND_DISPLAY / XDG_RUNTIME_DIR / *_INSTANCE_SIGNATURE recovered.

# shellcheck source=/dev/null
. "$(dirname "${BASH_SOURCE[0]:-$0}")/_wayland-env.sh"

if [ -z "${COMPOSITOR:-}" ]; then
  case "$(printf '%s' "${XDG_CURRENT_DESKTOP:-}" | tr '[:upper:]' '[:lower:]')" in
    *hyprland*) COMPOSITOR=hyprland ;;
    *mango*)    COMPOSITOR=mango ;;
    *)
      # XDG_CURRENT_DESKTOP can be missing when a script is spawned without a
      # full env (systemd units, quickshell Process). Fall back to what's running.
      if pgrep -x Hyprland >/dev/null 2>&1; then
        COMPOSITOR=hyprland
      elif pgrep -x mango >/dev/null 2>&1; then
        COMPOSITOR=mango
      else
        COMPOSITOR=other
      fi
      ;;
  esac
  export COMPOSITOR
fi

# List every connected output, one name per line. Empty on an unknown compositor.
compositor_monitors() {
  case "$COMPOSITOR" in
    hyprland) hyprctl -j monitors 2>/dev/null | jq -r '.[].name' ;;
    mango)    mmsg get all-monitors 2>/dev/null | jq -r '.monitors[].name' ;;
  esac
}

# Name of the output the pointer/focus is currently on.
compositor_focused_monitor() {
  case "$COMPOSITOR" in
    hyprland) hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused) | .name' | head -1 ;;
    mango)    mmsg get all-monitors 2>/dev/null | jq -r '.monitors[] | select(.active) | .name' | head -1 ;;
  esac
}
