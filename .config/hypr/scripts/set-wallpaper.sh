#!/bin/bash

# Script to set a wallpaper and generate a color scheme
# Usage: set-wallpaper.sh /path/to/wallpaper

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Check if a wallpaper was provided
if [ -z "${1:-}" ]; then
    echo "Usage: $0 /path/to/wallpaper"
    echo "Error: No wallpaper path provided"
    exit 1
fi

WALLPAPER="$1"
LOG_FILE="${LOG_FILE:-$HOME/.cache/hypr/wallpaper.log}"
CURRENT_WALLPAPER_FILE="${CURRENT_WALLPAPER_FILE:-$HOME/.cache/hypr/current-wallpaper.txt}"
TRANSITION_TYPE="${TRANSITION_TYPE:-any}"
TRANSITION_FPS="${TRANSITION_FPS:-60}"
VERBOSE="${VERBOSE:-false}"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    local level="${1:-INFO}"
    shift
    if [ "$level" = "VERBOSE" ] && [ "$VERBOSE" != "true" ]; then
        return
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
    if [ "$VERBOSE" = "true" ] || [ "$level" != "VERBOSE" ]; then
        echo "[$level] $*" >&2
    fi
}

# Error function
error() {
    log "ERROR" "$*"
    echo "Error: $*" >&2
    exit 1
}

# Save current wallpaper path
save_current() {
    local wallpaper="$1"
    mkdir -p "$(dirname "$CURRENT_WALLPAPER_FILE")"
    echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"
}

log "INFO" "Setting wallpaper: $WALLPAPER"

# Validate file exists
if [ ! -f "$WALLPAPER" ]; then
    error "Wallpaper file does not exist: $WALLPAPER"
fi

# Validate it's an image file
if ! file "$WALLPAPER" | grep -qiE 'image|bitmap'; then
    error "File does not appear to be an image: $WALLPAPER"
fi

# Check if required commands exist
for cmd in wal awww; do
    if ! command -v "$cmd" &>/dev/null; then
        error "Missing required command: $cmd. Please install it."
    fi
done

# Save current wallpaper
save_current "$WALLPAPER"

# 1. Generate color scheme with Pywal (optional)
#    The '-n' flag skips setting the wallpaper, as awww will handle it.
#    The '-q' flag makes it run quietly.
if command -v wal &>/dev/null; then
    log "INFO" "Generating color scheme with Pywal..."
    if ! wal -i "$WALLPAPER" -n -q 2>>"$LOG_FILE"; then
        log "WARNING" "Pywal failed to generate color scheme (non-critical)"
        log "WARNING" "You may need to reinstall pywal: pip install --user pywal"
    fi
else
    log "WARNING" "Pywal (wal) not found, skipping color scheme generation"
fi

# 2. Set the wallpaper with awww
log "INFO" "Setting wallpaper with awww..."
log "VERBOSE" "Using transition: $TRANSITION_TYPE at $TRANSITION_FPS fps"
if ! awww img "$WALLPAPER" --transition-type "$TRANSITION_TYPE" --transition-fps "$TRANSITION_FPS" 2>>"$LOG_FILE"; then
    error "awww failed to set wallpaper: $WALLPAPER"
fi

log "INFO" "Done. Wallpaper set successfully."
WALLPAPER_NAME=$(basename "$WALLPAPER")
echo "Wallpaper set successfully: $WALLPAPER_NAME"
notify-send -u low "Wallpaper Changed" "Set to: $WALLPAPER_NAME" 2>/dev/null || true
