#!/usr/bin/env bash
# Region GIF recorder — the moving-picture sibling of screenshot-region.sh.
# First press picks a region and starts recording; pressing the same key again
# stops it, encodes a GIF, and puts the file on the clipboard as a file URI
# (pastes as a file into browsers/chat, as the path into text fields).
# Knobs: FPS=15 WIDTH=800 screenshot-gif.sh
set -e

# Self-check for the only part that can silently produce a bad file: the encode.
if [ "${1:-}" = "--selftest" ]; then
  d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
  ffmpeg -loglevel error -y -f lavfi -i "testsrc=size=1920x1080:rate=30:duration=2" "$d/r.mkv"
  filters="fps=15,scale='min(800,iw)':-2:flags=lanczos"
  ffmpeg -loglevel error -y -i "$d/r.mkv" -vf "$filters,palettegen=stats_mode=diff" "$d/p.png"
  ffmpeg -loglevel error -y -i "$d/r.mkv" -i "$d/p.png" \
    -lavfi "${filters}[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" "$d/o.gif"
  got=$(ffprobe -v error -select_streams v -show_entries stream=width,nb_frames -of csv=p=0 "$d/o.gif")
  [ "$got" = "800,30" ] || { echo "selftest FAIL: expected 800,30 got $got" >&2; exit 1; }
  command -v wf-recorder >/dev/null || { echo "selftest FAIL: wf-recorder not installed" >&2; exit 1; }
  echo "selftest OK"; exit 0
fi

. "$(dirname "$0")/_wayland-env.sh"

C="${XDG_CACHE_HOME:-$HOME/.cache}"
PID="$C/gif-recorder.pid"
RAW="$C/gif-recorder.mkv"
PAL="$C/gif-recorder-palette.png"
OUT="$HOME/Pictures/gifs/$(date +%Y-%m-%d_%H-%M-%S).gif"
FPS="${FPS:-15}"
WIDTH="${WIDTH:-800}"

# Second press: SIGINT the recorder so it finalises the file. The first
# invocation is still blocked on `wait` below and does the encoding.
if [ -f "$PID" ]; then
  kill -INT "$(cat "$PID")" 2>/dev/null && exit 0
  rm -f "$PID" # stale pidfile, fall through and start a new recording
fi

g=$(slurp) || exit 0
[ -z "$g" ] && exit 0

mkdir -p "$(dirname "$OUT")" "$C"
rm -f "$RAW"
notify-send "Recording GIF" "Press the same key again to stop." -i media-record

wf-recorder -g "$g" -f "$RAW" &
rec=$!
echo "$rec" >"$PID"
trap 'kill -INT "$rec" 2>/dev/null; rm -f "$PID"' EXIT
wait "$rec" || true
trap - EXIT
rm -f "$PID"

[ -s "$RAW" ] || { notify-send "GIF failed" "Nothing was recorded." -i error; exit 1; }

# Two-pass palette: a shared palette is the difference between a usable GIF and
# a 20 MB dithered mess. ponytail: gifski would look better, ffmpeg is already here.
filters="fps=$FPS,scale='min($WIDTH,iw)':-2:flags=lanczos"
ffmpeg -loglevel error -y -i "$RAW" -vf "$filters,palettegen=stats_mode=diff" "$PAL"
ffmpeg -loglevel error -y -i "$RAW" -i "$PAL" \
  -lavfi "${filters}[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" "$OUT"
rm -f "$RAW" "$PAL"

wl-copy -t text/uri-list "file://$OUT"
notify-send "GIF copied" "$(du -h "$OUT" | cut -f1) — $OUT" -i "$OUT"
