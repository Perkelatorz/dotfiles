#!/usr/bin/env bash
# Opens the Quickshell workspace overview (keyboard-only, no bar button).
# In Hyprland, e.g.: bind = $mainMod, W, exec, ~/.config/scripts/open-workspace-overview.sh
touch "${XDG_RUNTIME_DIR:-/tmp}/quickshell-open-overview"
