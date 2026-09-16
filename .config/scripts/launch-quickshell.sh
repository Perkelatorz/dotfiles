#!/usr/bin/env bash
# Launch Quickshell bar. Used from hypr autostart.conf:
#   exec-once = ~/.config/scripts/launch-quickshell.sh &
# exec-once already runs post-compositor-init, so no sleep needed, and
# XDG_CURRENT_DESKTOP is set by the session (Hyprland/uwsm) — forcing it here
# would defeat shell.qml's compositor detection on non-Hyprland machines.
# Through systemd-cat, so the shell's own output lands in the journal
# (`journalctl --user -t quickshell`). exec-once gives this no terminal, so
# without it every warning quickshell prints -- including the lock screen
# failing to start a PAM conversation -- goes to a closed fd. A lock screen
# that would not unlock overnight left no trace anywhere for exactly this
# reason; the only record of the incident was `last reboot`.
exec systemd-cat -t quickshell --stderr-priority=warning \
    quickshell -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/shell.qml"
