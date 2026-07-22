#!/usr/bin/env bash
# Alt-Tab window cycler for Hyprland.
#
# Native cyclenext only cycles within the current workspace, and
# focusurgentorlast only toggles between the last two. This walks EVERY open
# window across all monitors/workspaces in a stable order and focuses the next
# one, switching workspace as needed. Stateless: order is deterministic
# (monitor → workspace → x → y), so forward/back are exact inverses.
#
#   alt-tab-cycle.sh          # focus next window
#   alt-tab-cycle.sh prev     # focus previous window
set -euo pipefail

dir="${1:-next}"

hyprctl -j clients | DIR="$dir" python3 -c '
import json, os, subprocess, sys

wins = [w for w in json.load(sys.stdin) if w.get("mapped") and w.get("workspace", {}).get("id", -1) >= 0]
if not wins:
    sys.exit(0)

# Stable order across the whole layout.
wins.sort(key=lambda w: (w["monitor"], w["workspace"]["id"], w["at"][0], w["at"][1]))

addrs = [w["address"] for w in wins]

active = json.loads(subprocess.check_output(["hyprctl", "-j", "activewindow"]) or "{}")
cur = active.get("address")

step = -1 if os.environ["DIR"] == "prev" else 1
i = addrs.index(cur) if cur in addrs else -step  # so first press lands on index 0 for "next"
nxt = addrs[(i + step) % len(addrs)]

subprocess.run(["hyprctl", "dispatch", "focuswindow", f"address:{nxt}"], check=False)
'
