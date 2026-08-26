#!/usr/bin/env bash
# Wake every display. No-op when they are already on, so it's safe to fire from
# hypridle's on-resume on every input event.
#
# WAKE ORDER MATTERS ON NVIDIA. The GPU has four hardware heads, and a mode with
# a high enough pixel clock is driven by TWO ganged heads rather than one (see
# /usr/share/doc/nvidia/README, "MaxOneHardwareHead"). DP-2 runs 3840x2160@240,
# which is 2331.75 MHz and needs DSC — a two-head mode.
#
# Waking outputs in enumeration order lets DP-2 claim its pair first, after which
# DP-3 has nothing left to allocate. The driver logs
#     nvidia-modeset: ERROR: Invalid request parameters, planePitch or
#     rmObjectSizeInBytes, passed during surface registration
# and the compositor gives up and marks the output disabled — permanently, since
# neither wakeup_monitor, enable_monitor, nor reload_config will retry it.
# The result is an ultrawide that never comes back from a screen blank.
#
# So: wake the single-head outputs first and the two-head hog LAST. If anything
# still fails, the recovery pass below sleeps the hog to release its heads, wakes
# the stragglers, then brings the hog back.
set -euo pipefail

# shellcheck source=/dev/null
. "$(dirname "$0")/_compositor.sh"

# Space-separated output names that must be woken last. Re-check after any cable
# move or driver update — connector names are not stable. Use ~/.local/bin/which-port.
: "${WAKE_LAST:=DP-2}"

# Connected outputs that the kernel says are NOT currently enabled.
failed_outputs() {
	local c name
	for c in /sys/class/drm/card*-*; do
		[ -e "$c/status" ] || continue
		[ "$(cat "$c/status")" = connected ] || continue
		[ "$(cat "$c/enabled")" = enabled ] && continue
		name=$(basename "$c")
		printf '%s\n' "${name#card*-}"
	done
}

is_wake_last() {
	local m
	for m in $WAKE_LAST; do
		[ "$1" = "$m" ] && return 0
	done
	return 1
}

wake_mango() {
	local m first=() last=()

	while IFS= read -r m; do
		[ -n "$m" ] || continue
		if is_wake_last "$m"; then last+=("$m"); else first+=("$m"); fi
	done < <(compositor_monitors)

	for m in ${first[@]+"${first[@]}"} ${last[@]+"${last[@]}"}; do
		mmsg dispatch "wakeup_monitor,$m" >/dev/null 2>&1 || true
		sleep 0.3
	done

	# Give the modesets time to land before judging them.
	sleep 1.5

	local stragglers
	stragglers=$(failed_outputs)
	[ -n "$stragglers" ] || return 0

	# Recovery: release the hog's heads, wake whatever failed, restore the hog.
	for m in $WAKE_LAST; do
		mmsg dispatch "sleep_monitor,$m" >/dev/null 2>&1 || true
	done
	sleep 1

	for m in $stragglers; do
		mmsg dispatch "wakeup_monitor,$m" >/dev/null 2>&1 || true
		sleep 0.5
	done

	for m in $WAKE_LAST; do
		mmsg dispatch "wakeup_monitor,$m" >/dev/null 2>&1 || true
		sleep 0.5
	done
}

case "$COMPOSITOR" in
  hyprland)
    hyprctl dispatch dpms on
    ;;
  mango)
    wake_mango
    ;;
  *)
    echo "screen-on: unsupported compositor '${COMPOSITOR}'" >&2
    exit 1
    ;;
esac
