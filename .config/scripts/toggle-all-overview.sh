#!/usr/bin/env bash
# Toggle MangoWC overview on ALL monitors simultaneously.
# Focuses each monitor briefly to toggle its overview, then returns focus.

mapfile -t outputs < <(mmsg -g -o 2>/dev/null | awk '{print $1}')
focused=$(mmsg -g -o 2>/dev/null | awk '$3 == 1 {print $1}')

for out in "${outputs[@]}"; do
    [ -z "$out" ] && continue
    mmsg -d "focusmon,$out" 2>/dev/null
    sleep 0.02
    mmsg -d toggleoverview 2>/dev/null
    sleep 0.02
done

[ -n "$focused" ] && mmsg -d "focusmon,$focused" 2>/dev/null
