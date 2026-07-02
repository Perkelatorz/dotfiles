#!/usr/bin/env bash
# Launch Quickshell bar. Used from hypr autostart.conf:
#   exec-once = ~/.config/scripts/launch-quickshell.sh &
# exec-once already runs post-compositor-init, so no sleep needed, and
# XDG_CURRENT_DESKTOP is set by the session (Hyprland/uwsm) — forcing it here
# would defeat shell.qml's compositor detection on non-Hyprland machines.
exec quickshell -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/shell.qml"
