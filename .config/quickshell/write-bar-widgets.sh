#!/bin/sh
# Writes bar widget visibility to bar-widgets.json from key=value args.
# Usage: write-bar-widgets.sh volume=true battery=false ...
F="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/bar-widgets.json"
first=1
printf '%s' '{' > "$F"
for a in "$@"; do
    k="${a%%=*}"
    v="${a#*=}"
    [ $first -eq 0 ] && printf '%s' ',' >> "$F"
    printf '%s' "\"$k\":$v" >> "$F"
    first=0
done
printf '%s\n' '}' >> "$F"
