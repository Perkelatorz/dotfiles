#!/bin/sh

run() {
    if ! pgrep -f "$1"; then
        "$@" &
    fi
}


run "nm-applet" &
run "picom" -b &
run "cp" $(cat ~/.cache/wal/wal) ~/.cache/wal/wal.jpg
run "pasystray" &

# run "" &
