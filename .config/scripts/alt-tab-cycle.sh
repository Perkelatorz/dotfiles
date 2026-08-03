#!/usr/bin/env bash
# Alt-Tab window cycler. Works under Hyprland and mango.
#
# Both compositors only cycle within the current workspace/stack natively
# (Hyprland cyclenext, mango focusstack), and their "last window" dispatchers
# only toggle between two. This walks EVERY open window across all
# monitors/workspaces in a stable order and focuses the next one, switching
# workspace/tag as needed. Stateless: order is deterministic
# (monitor → workspace → x → y), so forward/back are exact inverses.
#
#   alt-tab-cycle.sh          # focus next window
#   alt-tab-cycle.sh prev     # focus previous window
set -euo pipefail

# shellcheck source=/dev/null
. "$(dirname "$0")/_compositor.sh"

dir="${1:-next}"

case "$COMPOSITOR" in
  hyprland)
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
    ;;

  mango)
    mmsg get all-clients | DIR="$dir" python3 -c '
import json, os, subprocess, sys

data = json.load(sys.stdin)
wins = [c for c in data.get("clients", [])
        if not c.get("is_minimized") and not c.get("is_scratchpad") and c.get("monitor")]
if not wins:
    sys.exit(0)

def tag_of(c):
    # "tags" is an array of the tag indices the client lives on; sort by the
    # lowest so a window pinned to several tags keeps a stable slot.
    tags = c.get("tags") or [0]
    return min(tags)

wins.sort(key=lambda c: (c["monitor"], tag_of(c), c["x"], c["y"]))

ids = [c["id"] for c in wins]
cur = next((c["id"] for c in wins if c.get("is_focused")), None)

step = -1 if os.environ["DIR"] == "prev" else 1
i = ids.index(cur) if cur in ids else -step  # first press lands on index 0 for "next"
nxt = ids[(i + step) % len(ids)]

# focusid follows the client to its tag/monitor, the same way Hyprland
# focuswindow does. mmsg echoes a JSON ack; swallow it so the script stays quiet.
subprocess.run(["mmsg", "dispatch", "focusid", f"client,{nxt}"], check=False,
               stdout=subprocess.DEVNULL)
'
    ;;

  *)
    echo "alt-tab-cycle: unsupported compositor '${COMPOSITOR}'" >&2
    exit 1
    ;;
esac
