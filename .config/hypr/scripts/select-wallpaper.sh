#!/bin/bash

# ---
# A HYBRID script that uses Pywal for instant theming and then updates WPGtk.
# This script is the primary driver for changing themes.
# ---

set -uo pipefail  # Exit on undefined vars, pipe failures
# Note: We don't use 'set -e' because we want to handle errors gracefully

# --- CONFIGURATION ---
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures}"
# Support multiple directories (colon-separated)
WALLPAPER_DIRS="${WALLPAPER_DIRS:-$WALLPAPER_DIR}"
WAYBAR_DIR="${WAYBAR_DIR:-$HOME/.config/waybar}"
LOG_FILE="${LOG_FILE:-$HOME/.cache/hypr/wallpaper.log}"
RECENT_FILE="${RECENT_FILE:-$HOME/.cache/hypr/recent-wallpapers.txt}"
CURRENT_WALLPAPER_FILE="${CURRENT_WALLPAPER_FILE:-$HOME/.cache/hypr/current-wallpaper.txt}"
MAX_RECENT="${MAX_RECENT:-10}"
VERBOSE="${VERBOSE:-false}"
SKIP_WPGTK="${SKIP_WPGTK:-false}"

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
    notify-send -u critical "Wallpaper Script Error" "$*" 2>/dev/null || true
    exit 1
}

# Save to recent wallpapers
save_to_recent() {
    local wallpaper="$1"
    mkdir -p "$(dirname "$RECENT_FILE")"
    # Remove if already exists, then prepend
    grep -v "^${wallpaper}$" "$RECENT_FILE" 2>/dev/null > "${RECENT_FILE}.tmp" || true
    echo "$wallpaper" > "$RECENT_FILE"
    head -n $((MAX_RECENT - 1)) "${RECENT_FILE}.tmp" 2>/dev/null >> "$RECENT_FILE" || true
    rm -f "${RECENT_FILE}.tmp"
}

# Save current wallpaper path
save_current() {
    local wallpaper="$1"
    mkdir -p "$(dirname "$CURRENT_WALLPAPER_FILE")"
    echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"
}

# Check if required commands exist
check_dependencies() {
    local missing=()
    local optional_missing=()
    
    # Required commands
    for cmd in rofi awww; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    # Optional but recommended commands
    if ! command -v wal &>/dev/null; then
        optional_missing+=("wal (pywal)")
    fi
    if ! command -v wpg &>/dev/null; then
        optional_missing+=("wpg (wpgtk)")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing required commands: ${missing[*]}. Please install them."
    fi
    
    if [ ${#optional_missing[@]} -gt 0 ]; then
        log "WARNING" "Optional commands not found: ${optional_missing[*]}. Some features will be disabled."
    fi
}

# --- SCRIPT LOGIC ---

log "INFO" "Starting wallpaper selection script"

# Check dependencies
check_dependencies

# Collect wallpapers from all directories
log "INFO" "Scanning for wallpapers..."
WALLPAPER_LIST=""

# Save original IFS
OLD_IFS="$IFS"
IFS=':'
for dir in $WALLPAPER_DIRS; do
    IFS="$OLD_IFS"
    if [ ! -d "$dir" ]; then
        log "VERBOSE" "Skipping non-existent directory: $dir"
        continue
    fi
    log "VERBOSE" "Scanning directory: $dir"
    FOUND=$(find "$dir" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.webp' \) 2>/dev/null)
    if [ -n "$FOUND" ]; then
        WALLPAPER_LIST="${WALLPAPER_LIST}${WALLPAPER_LIST:+$'\n'}${FOUND}"
    fi
    IFS=':'
done
IFS="$OLD_IFS"

# Sort and deduplicate
WALLPAPER_LIST=$(echo "$WALLPAPER_LIST" | sort -u)

if [ -z "$WALLPAPER_LIST" ]; then
    error "No images found in any of the wallpaper directories: $WALLPAPER_DIRS"
fi

WALLPAPER_COUNT=$(echo "$WALLPAPER_LIST" | grep -c . || echo "0")
log "INFO" "Found $WALLPAPER_COUNT wallpapers"

# Load recent wallpapers if file exists
RECENT_LIST=""
if [ -f "$RECENT_FILE" ] && [ -s "$RECENT_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        if [ -n "$line" ] && [ -f "$line" ]; then
            RECENT_LIST="${RECENT_LIST}${RECENT_LIST:+$'\n'}⭐ $(basename "$line")|$line"
        fi
    done < <(head -n 5 "$RECENT_FILE")
fi

# Build selection menu
SELECTION=$( (
  echo "🎲 Random"
  [ -n "$RECENT_LIST" ] && echo "$RECENT_LIST" && echo "---"
  echo "$WALLPAPER_LIST"
) | rofi -dmenu -i -p "Select Wallpaper ($WALLPAPER_COUNT found)")

# 2. Handle the user's selection
if [ -z "$SELECTION" ]; then
    log "INFO" "No wallpaper selected by user"
    exit 0
elif [ "$SELECTION" = "🎲 Random" ]; then
    FINAL_WALLPAPER=$(echo "$WALLPAPER_LIST" | shuf -n 1)
    log "INFO" "Selected random wallpaper: $FINAL_WALLPAPER"
elif [[ "$SELECTION" == *"|"* ]]; then
    # Handle recent wallpaper format: "⭐ name|path"
    FINAL_WALLPAPER="${SELECTION##*|}"
    log "INFO" "Selected recent wallpaper: $FINAL_WALLPAPER"
else
    FINAL_WALLPAPER="$SELECTION"
    log "INFO" "Selected wallpaper: $FINAL_WALLPAPER"
fi

# Validate selected file exists
if [ ! -f "$FINAL_WALLPAPER" ]; then
    error "Selected file does not exist: $FINAL_WALLPAPER"
fi

# --- THEME GENERATION & APPLICATION ---

log "INFO" "--- Starting Theme Update ---"

# Save current wallpaper
save_current "$FINAL_WALLPAPER"
save_to_recent "$FINAL_WALLPAPER"

# Step A: Run Pywal for instant Terminal/Waybar theme (optional)
# Always try to run Pywal to regenerate colors, but handle failures gracefully
CURRENT_WALPAPER_FILE="$HOME/.cache/wal/wal"
WALPAPER_MATCHES=false

# Check if colors already exist for this wallpaper (for informational purposes)
if [ -f "$CURRENT_WALPAPER_FILE" ] && [ -f "$HOME/.cache/wal/colors.sh" ]; then
    CACHED_WALLPAPER=$(cat "$CURRENT_WALPAPER_FILE" 2>/dev/null || echo "")
    # Normalize paths for comparison (resolve symlinks)
    CACHED_NORM=$(readlink -f "$CACHED_WALLPAPER" 2>/dev/null || echo "$CACHED_WALLPAPER")
    FINAL_NORM=$(readlink -f "$FINAL_WALLPAPER" 2>/dev/null || echo "$FINAL_WALLPAPER")
    
    if [ "$CACHED_NORM" = "$FINAL_NORM" ]; then
        WALPAPER_MATCHES=true
        log "VERBOSE" "Pywal colors already exist for this wallpaper, regenerating..."
    fi
fi

if command -v wal &>/dev/null; then
    log "INFO" "🎨 [Pywal] Generating/regenerating theme..."
    
    # Always try to run Pywal to ensure colors are up to date
    # Capture both stdout and stderr, don't fail on error
    WAL_OUTPUT=$(wal -q -i "$FINAL_WALLPAPER" 2>&1) || WAL_EXIT=$?
    WAL_EXIT=${WAL_EXIT:-0}
    
    if [ $WAL_EXIT -ne 0 ]; then
        log "WARNING" "Pywal failed to generate theme (pywal may have package issues)"
        log "VERBOSE" "Pywal error: $WAL_OUTPUT"
        
        # Check if we have any cached colors to fall back to
        if [ -f "$HOME/.cache/wal/colors.sh" ]; then
            log "INFO" "Using existing Pywal colors from cache as fallback"
            WALPAPER_MATCHES=true
        else
            log "WARNING" "No cached colors available. Theme generation skipped."
            log "WARNING" "To fix Pywal: pip install --user --force-reinstall pywal"
        fi
    else
        log "INFO" "✓ Pywal theme generated/regenerated successfully"
        WALPAPER_MATCHES=true
    fi
else
    log "WARNING" "Pywal (wal) not found, checking for existing colors..."
    if [ -f "$HOME/.cache/wal/colors.sh" ]; then
        log "INFO" "Using existing Pywal colors from cache"
        WALPAPER_MATCHES=true
    else
        log "WARNING" "No Pywal colors found, theme generation will be skipped"
    fi
fi

# Check if colors.sh exists for Waybar CSS update
if [ ! -f "$HOME/.cache/wal/colors.sh" ]; then
    log "WARNING" "Pywal colors.sh not found. Waybar CSS update will be skipped."
else
    log "INFO" "Pywal colors.sh found, will update Waybar CSS"
fi

# Step B: Set the wallpaper using your preferred tool
log "INFO" "🖼️ [awww] Setting wallpaper..."
TRANSITION_TYPE="${TRANSITION_TYPE:-any}"
TRANSITION_FPS="${TRANSITION_FPS:-60}"
if ! awww img "$FINAL_WALLPAPER" --transition-type "$TRANSITION_TYPE" --transition-fps "$TRANSITION_FPS" 2>>"$LOG_FILE"; then
    error "awww failed to set wallpaper: $FINAL_WALLPAPER"
fi

# Step C: Update Waybar's CSS from Pywal's cache (if available)
if [ -d "$WAYBAR_DIR" ]; then
    log "INFO" "🎨 [Waybar] Updating Waybar CSS..."
    
    # Check if colors.sh exists
    if [ ! -f "$HOME/.cache/wal/colors.sh" ]; then
        log "WARNING" "Pywal colors.sh not found, skipping Waybar CSS update"
        log "VERBOSE" "To fix: Install/reinstall pywal or run: wal -i \"$FINAL_WALLPAPER\" manually"
    else
        # Source colors.sh safely
        if ! source "$HOME/.cache/wal/colors.sh" 2>/dev/null; then
            log "WARNING" "Failed to source colors.sh, skipping Waybar CSS update"
        else
            # Generate CSS file
            log "VERBOSE" "Generating Waybar CSS from Pywal colors..."
            CSS_FILE="$WAYBAR_DIR/pywal-colors.css"
            CSS_TEMP="${CSS_FILE}.tmp"
            
            (
                cat <<EOF
/* Pywal colors for Waybar - Auto-generated by select-wallpaper.sh */
/* Generated: $(date) */
@define-color background ${background}; @define-color foreground ${foreground}; @define-color cursor ${cursor};
@define-color color0 ${color0}; @define-color color1 ${color1}; @define-color color2 ${color2}; @define-color color3 ${color3};
@define-color color4 ${color4}; @define-color color5 ${color5}; @define-color color6 ${color6}; @define-color color7 ${color7};
@define-color color8 ${color8}; @define-color color9 ${color9}; @define-color color10 ${color10}; @define-color color11 ${color11};
@define-color color12 ${color12}; @define-color color13 ${color13}; @define-color color14 ${color14}; @define-color color15 ${color15};
EOF
            ) | sed "s/'//g" >"$CSS_TEMP"
            
            # Only update if content changed (to trigger waybar reload)
            if ! cmp -s "$CSS_TEMP" "$CSS_FILE" 2>/dev/null; then
                mv "$CSS_TEMP" "$CSS_FILE"
                log "INFO" "✓ Waybar CSS file updated with new colors"
                CSS_CHANGED=true
            else
                rm -f "$CSS_TEMP"
                log "VERBOSE" "Waybar CSS unchanged (colors are the same)"
                CSS_CHANGED=false
            fi
            
            # Check if waybar config references this CSS file
            if [ -f "$WAYBAR_DIR/config" ] || [ -f "$WAYBAR_DIR/config.jsonc" ] || [ -f "$WAYBAR_DIR/config.json" ]; then
                log "VERBOSE" "Waybar config found, CSS should be imported"
            fi
            
            # Reload waybar if it's running
            if pgrep -x waybar >/dev/null; then
                if [ "$CSS_CHANGED" = "true" ]; then
                    log "INFO" "Reloading Waybar to apply new colors..."
                else
                    log "VERBOSE" "Reloading Waybar..."
                fi
                
                # Try multiple reload methods
                WAYBAR_PID=$(pgrep -x waybar | head -1)
                
                # Method 1: SIGUSR2 (standard waybar reload signal)
                if kill -SIGUSR2 "$WAYBAR_PID" 2>/dev/null; then
                    sleep 0.3  # Give waybar time to reload
                    log "VERBOSE" "Sent SIGUSR2 to waybar (PID: $WAYBAR_PID)"
                else
                    log "WARNING" "Failed to send SIGUSR2 to waybar"
                fi
                
                # Method 2: Alternative - use killall
                if ! killall -0 waybar 2>/dev/null; then
                    log "WARNING" "Waybar stopped unexpectedly"
                fi
                
                # Verify waybar is still running and CSS was loaded
                if pgrep -x waybar >/dev/null; then
                    log "INFO" "✓ Waybar reloaded (check if colors updated)"
                else
                    log "WARNING" "Waybar may have crashed, check logs"
                fi
            else
                log "VERBOSE" "Waybar is not running, CSS will be loaded on next start"
            fi
        fi
    fi
else
    log "VERBOSE" "Waybar directory not found: $WAYBAR_DIR, skipping CSS update"
fi

# Step D: Update WPGtk with the same wallpaper (optional)
if [ "$SKIP_WPGTK" != "true" ] && command -v wpg &>/dev/null; then
    log "INFO" "🎨 [WPGtk] Syncing theme..."
    if ! wpg -s "$FINAL_WALLPAPER" 2>>"$LOG_FILE"; then
        log "WARNING" "WPGtk failed to sync theme (this is non-critical)"
    fi
elif [ "$SKIP_WPGTK" = "true" ]; then
    log "VERBOSE" "Skipping WPGtk sync (SKIP_WPGTK=true)"
else
    log "VERBOSE" "WPGtk (wpg) not found, skipping theme sync"
fi

log "INFO" "✅ Theme updated successfully!"
WALLPAPER_NAME=$(basename "$FINAL_WALLPAPER")
notify-send -u low "Wallpaper Changed" "Theme updated: $WALLPAPER_NAME" 2>/dev/null || true
