#!/usr/bin/env bash
# Launch Quickshell bar after a short delay so Hyprland/Wayland is ready.
# Used from autostart.conf: exec-once = ~/.config/hypr/scripts/launch-quickshell.sh &
sleep 2
export XDG_CURRENT_DESKTOP=hyprland
exec /usr/bin/quickshell shell ~/.config/quickshell/shell.qml
