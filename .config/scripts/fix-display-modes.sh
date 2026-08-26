#!/usr/bin/env bash
# Repair outputs that came up at the wrong mode, then exit. Safe to run anytime:
# it is a no-op when every output already matches its monitorrule.
#
# WHY THIS EXISTS (boot path). Same four-head allocation problem documented at
# the top of screen-on.sh: DP-2 runs 3840x2160@240 (2331.75 MHz, DSC), which the
# driver drives with TWO ganged hardware heads out of the GPU's four. If DP-2
# claims its pair before the ultrawide has a head, DP-3 gets nothing, the driver
# logs
#     nvidia-modeset: ERROR: Invalid request parameters, planePitch or
#     rmObjectSizeInBytes, passed during surface registration
# and mango falls the output back to 640x480 -- wlroots' "no mode could be set"
# resolution. Ordering the rules in monitors.conf does not help: mango applies
# them in connector-enumeration order, not file order.
#
# screen-on.sh already fixes this for wake-from-blank, but it is wired only into
# idle.conf (on-resume / after_sleep_cmd), so nothing repairs the BOOT case. It
# also would not detect this one: after a failed boot modeset the connector is
# still status=connected enabled=enabled, so screen-on.sh's failed_outputs(),
# which looks for connected-but-disabled, sees nothing wrong. Hence the check
# below compares the ACTUAL mode against the configured monitorrule instead.
#
# The repair: release the two-head hog so its pair is free, reload_config so
# mango re-applies every monitorrule while the stragglers can actually claim a
# head, then bring the hog back to reclaim its pair.
#
# Note sleep_monitor/wakeup_monitor alone is NOT enough here. Waking an output
# restores the mode it last held, not the one its monitorrule asks for, so an
# output stranded at 640x480 just comes back at 640x480. reload_config is what
# re-applies the rule -- but on its own it fails too, because the hog is still
# holding its heads. Only the two together work.
set -euo pipefail

# shellcheck source=/dev/null
. "$(dirname "$0")/_compositor.sh"

CONF="${CONF:-$HOME/.config/mango/monitors.conf}"
# Outputs whose mode needs two ganged heads, so they must be brought up LAST.
# Re-check after any cable move or driver update -- connector names are not
# stable. Use ~/.local/bin/which-port.
: "${WAKE_LAST:=DP-2}"
# Outputs are still settling right after login; give them time before judging.
: "${SETTLE:=6}"
: "${TRIES:=5}"

log() { printf 'fix-display-modes: %s\n' "$*" >&2; }

# Names of connected outputs whose current logical size does not match the size
# their monitorrule asks for. Empty output means everything is correct.
mismatched() {
	mmsg get all-monitors 2>/dev/null | python3 -c '
import json, re, sys, os

conf = os.environ["CONF"]
rules = {}
for line in open(conf):
    line = line.strip()
    if not line.startswith("monitorrule="):
        continue
    f = dict(re.findall(r"(\w+):([^,]+)", line[len("monitorrule="):]))
    name = f.get("name", "").strip("^$")
    if not name:
        continue
    try:
        w, h = int(f["width"]), int(f["height"])
        scale = float(f.get("scale", 1)) or 1.0
        rr = int(f.get("rr", 0))
    except (KeyError, ValueError):
        continue
    # rr 1/3 are the 90/270 rotations, which swap the logical axes.
    if rr in (1, 3):
        w, h = h, w
    rules[name] = (round(w / scale), round(h / scale))

try:
    mons = json.load(sys.stdin)["monitors"]
except Exception:
    sys.exit(0)

for m in mons:
    want = rules.get(m["name"])
    if not want:
        continue
    if (m["width"], m["height"]) != want:
        print(m["name"])
'
}

# Release the hog's head pair, re-apply every monitorrule while the heads are
# free, then restore the hog.
repair() {
	local m
	for m in $WAKE_LAST; do
		mmsg dispatch "sleep_monitor,$m" >/dev/null 2>&1 || true
	done
	sleep 1.5

	mmsg dispatch reload_config >/dev/null 2>&1 || true
	sleep 3

	for m in $WAKE_LAST; do
		mmsg dispatch "wakeup_monitor,$m" >/dev/null 2>&1 || true
		sleep 1
	done
	sleep 2
}

[ "$COMPOSITOR" = mango ] || { log "not mango (COMPOSITOR=$COMPOSITOR), nothing to do"; exit 0; }
export CONF

sleep "$SETTLE"

for _ in $(seq 1 "$TRIES"); do
	# shellcheck disable=SC2046
	set -- $(mismatched)
	[ $# -eq 0 ] && { log "all outputs match monitors.conf"; exit 0; }
	log "wrong mode on: $*"
	repair
done

# shellcheck disable=SC2046
set -- $(mismatched)
if [ $# -eq 0 ]; then
	log "all outputs match monitors.conf"
else
	log "STILL wrong after $TRIES attempts: $* (check which-port; connector names may have changed)"
	exit 1
fi
