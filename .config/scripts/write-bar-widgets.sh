#!/bin/sh
# Writes bar widget visibility to bar-widgets.json from key=value args.
# Usage: write-bar-widgets.sh volume=true battery=false ...
# Builds the JSON in memory and mv's atomically — the shell's reader can
# never observe a partially-written file.
F="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/bar-widgets.json"
json='{'
first=1
for a in "$@"; do
    k="${a%%=*}"
    v="${a#*=}"
    case "$v" in
        true|false) ;;
        *) continue ;;  # only booleans belong here
    esac
    [ $first -eq 0 ] && json="$json,"
    json="$json\"$k\":$v"
    first=0
done
json="$json}"
printf '%s\n' "$json" > "$F.tmp" && mv "$F.tmp" "$F"
