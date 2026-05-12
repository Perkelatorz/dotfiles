#!/usr/bin/env bash
# Opens Quickshell workspace overview via native IPC.
# Bind: Super+W in hypr/binds.conf → exec, ~/.config/scripts/open-workspace-overview.sh
exec qs ipc call shell openOverview
