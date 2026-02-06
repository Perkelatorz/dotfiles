#!/bin/bash

# ---
# A script that uses Matugen for Material Design 3 theming.
# Optimized for Quickshell and Hyprland.
# Two styles: Material (nice, muted) or Rainbow (vivid). Use --material or --rainbow to skip the menu.
# ---

set -uo pipefail

# --- STYLE: CLI or rofi (2 options only) ---
if [[ "${1:-}" == --help ]] || [[ "${1:-}" == -h ]]; then
  echo "Usage: $(basename "$0") [OPTION]"
  echo ""
  echo "Options:"
  echo "  --material   Material: subtle, harmonious, close to wallpaper"
  echo "  --rainbow    Rainbow: vivid, full color variety"
  echo ""
  echo "With no option, rofi asks: Style then Wallpaper."
  exit 0
fi
THEME_FROM_CLI="false"
if [[ "${1:-}" == --material ]]; then
  THEME_STYLE=material
  PALETTE_STYLE=material
  THEME_FROM_CLI="true"
  shift
elif [[ "${1:-}" == --rainbow ]]; then
  THEME_STYLE=rainbow
  PALETTE_STYLE=rainbow
  THEME_FROM_CLI="true"
  shift
fi

# --- STYLE MENU: 2 options (+ Random) ---
PICK_RANDOM_ALL="false"
if [[ "$THEME_FROM_CLI" != "true" ]]; then
  STYLE_MENU=$(echo -e "🎲 Random\nMaterial\nRainbow" | rofi -dmenu -i -p "Style")
  case "$STYLE_MENU" in
    *[Rr]andom*)
      if [[ $((RANDOM % 2)) -eq 0 ]]; then
        THEME_STYLE=material
        PALETTE_STYLE=material
      else
        THEME_STYLE=rainbow
        PALETTE_STYLE=rainbow
      fi
      PICK_RANDOM_ALL="true"
      ;;
    *[Mm]aterial*)
      THEME_STYLE=material
      PALETTE_STYLE=material
      ;;
    *[Rr]ainbow*)
      THEME_STYLE=rainbow
      PALETTE_STYLE=rainbow
      ;;
    "")
      THEME_STYLE=material
      PALETTE_STYLE=material
      ;;
    *)
      THEME_STYLE=material
      PALETTE_STYLE=material
      ;;
  esac
fi

PALETTE_STYLE="${PALETTE_STYLE:-material}"

# --- THEME STYLE PRESETS (only material + rainbow used now) ---
THEME_STYLE="${THEME_STYLE:-material}"

case "$THEME_STYLE" in
  material)
    # Material: subtle, harmonious, close to wallpaper
    DEFAULT_SCHEME="tonal-spot"
    DEFAULT_CONTRAST="0.0"
    DEFAULT_PREPROCESS="false"
    DEFAULT_PREPROCESS_SIZE="512"
    DEFAULT_PREPROCESS_SAT="100"
    ;;
  rainbow)
    # Rainbow: vivid, full color variety
    DEFAULT_SCHEME="expressive"
    DEFAULT_CONTRAST="0.35"
    DEFAULT_PREPROCESS="true"
    DEFAULT_PREPROCESS_SIZE="256"
    DEFAULT_PREPROCESS_SAT="120"
    ;;
  *)
    THEME_STYLE=material
    DEFAULT_SCHEME="tonal-spot"
    DEFAULT_CONTRAST="0.0"
    DEFAULT_PREPROCESS="false"
    DEFAULT_PREPROCESS_SIZE="512"
    DEFAULT_PREPROCESS_SAT="100"
    ;;
esac

# --- CONFIGURATION ---
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures}"
WALLPAPER_DIRS="${WALLPAPER_DIRS:-$WALLPAPER_DIR}"
QUICKSHELL_DIR="${QUICKSHELL_DIR:-$HOME/.config/quickshell}"
MATUGEN_CONFIG="$HOME/.config/matugen/config.toml"
LOG_FILE="$HOME/.cache/hypr/wallpaper.log"
CURRENT_WALLPAPER_FILE="$HOME/.cache/hypr/current-wallpaper.txt"
VERBOSE="${VERBOSE:-false}"

# Matugen Settings (can be overridden by env vars)
MATUGEN_MODE="${MATUGEN_MODE:-dark}"
MATUGEN_SCHEME="${MATUGEN_SCHEME:-$DEFAULT_SCHEME}"
MATUGEN_CONTRAST="${MATUGEN_CONTRAST:-$DEFAULT_CONTRAST}"
MATUGEN_SHOW_COLORS="${MATUGEN_SHOW_COLORS:-false}"
MATUGEN_DRY_RUN="${MATUGEN_DRY_RUN:-false}"
MATUGEN_RESIZE_FILTER="${MATUGEN_RESIZE_FILTER:-lanczos3}"

# Preprocessing (pywal-style color extraction)
PREPROCESS_FOR_PYWAL="${PREPROCESS_FOR_PYWAL:-$DEFAULT_PREPROCESS}"
PREPROCESS_SIZE="${PREPROCESS_SIZE:-$DEFAULT_PREPROCESS_SIZE}"
PREPROCESS_SAT="${PREPROCESS_SAT:-$DEFAULT_PREPROCESS_SAT}"

# High contrast text generation
GENERATE_HIGH_CONTRAST_TEXT="${GENERATE_HIGH_CONTRAST_TEXT:-true}"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
  local level="${1:-INFO}"
  shift
  if [ "$level" = "VERBOSE" ] && [ "$VERBOSE" != "true" ]; then return; fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

error() {
  log "ERROR" "$*"
  notify-send -u critical "Wallpaper Script Error" "$*" 2>/dev/null || true
  exit 1
}

save_current() {
  mkdir -p "$(dirname "$CURRENT_WALLPAPER_FILE")"
  echo "$1" > "$CURRENT_WALLPAPER_FILE"
}

check_dependencies() {
  local missing=()
  for cmd in rofi awww matugen; do
    if ! command -v "$cmd" &>/dev/null; then missing+=("$cmd"); fi
  done
  
  if [ ${#missing[@]} -gt 0 ]; then
    error "Missing required commands: ${missing[*]}. Please install them."
  fi
  
  # Warn if preprocessing is enabled but ImageMagick is missing
  if [ "$PREPROCESS_FOR_PYWAL" = "true" ] && ! command -v magick &>/dev/null && ! command -v convert &>/dev/null; then
    log "WARNING" "PREPROCESS_FOR_PYWAL=true but ImageMagick not found. Install 'imagemagick' for pywal-style preprocessing."
    PREPROCESS_FOR_PYWAL="false"
  fi
}

# Function to calculate luminance from hex color
get_luminance() {
  local hex="$1"
  # Remove # if present
  hex="${hex#\#}"
  
  # Extract RGB
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  
  # Convert to 0-1 range and apply sRGB gamma correction
  local r_norm=$(awk "BEGIN {printf \"%.6f\", $r/255.0}")
  local g_norm=$(awk "BEGIN {printf \"%.6f\", $g/255.0}")
  local b_norm=$(awk "BEGIN {printf \"%.6f\", $b/255.0}")
  
  # Calculate relative luminance (simplified)
  local lum=$(awk "BEGIN {printf \"%.6f\", 0.2126*$r_norm + 0.7152*$g_norm + 0.0722*$b_norm}")
  echo "$lum"
}

# Function to generate high contrast text color
generate_contrast_text() {
  local bg_color="$1"
  local lum=$(get_luminance "$bg_color")
  
  # If background is dark (lum < 0.5), return white/light
  # If background is light (lum >= 0.5), return black/dark
  if awk "BEGIN {exit !($lum < 0.5)}"; then
    echo "#ffffff"  # White for dark backgrounds
  else
    echo "#000000"  # Black for light backgrounds
  fi
}

# Function to generate accent text color (slightly less contrast but still readable)
generate_accent_text() {
  local bg_color="$1"
  local lum=$(get_luminance "$bg_color")
  
  if awk "BEGIN {exit !($lum < 0.5)}"; then
    echo "#e0e0e0"  # Light gray for dark backgrounds
  else
    echo "#1a1a1a"  # Dark gray for light backgrounds
  fi
}

# --- SCRIPT LOGIC ---

log "INFO" "Starting wallpaper selection script"
log "INFO" "Theme style: $THEME_STYLE, palette: $PALETTE_STYLE (scheme=$MATUGEN_SCHEME, contrast=$MATUGEN_CONTRAST, preprocess=$PREPROCESS_FOR_PYWAL)"
log "INFO" "Working directory: $(pwd)"
log "INFO" "HOME: $HOME"
check_dependencies

log "INFO" "Scanning for wallpapers..."
WALLPAPER_LIST=""
OLD_IFS="$IFS"
IFS=':'
for dir in $WALLPAPER_DIRS; do
  IFS="$OLD_IFS"
  # Expand tilde to absolute path
  dir="${dir/#\~/$HOME}"
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

WALLPAPER_LIST=$(echo "$WALLPAPER_LIST" | sort -u)
[ -z "$WALLPAPER_LIST" ] && error "No images found in $WALLPAPER_DIRS"

WALLPAPER_COUNT=$(echo "$WALLPAPER_LIST" | grep -c . || echo "0")
log "INFO" "Found $WALLPAPER_COUNT wallpapers"

# Pick random wallpaper by index (avoids shuf pipeline giving same result)
pick_random_wallpaper() {
  local -a arr
  while IFS= read -r line; do
    [[ -n "$line" ]] && arr+=("$line")
  done <<< "$WALLPAPER_LIST"
  local n=${#arr[@]}
  [[ $n -eq 0 ]] && return 1
  echo "${arr[$((RANDOM % n))]}"
}

if [ "$PICK_RANDOM_ALL" = "true" ]; then
  FINAL_WALLPAPER=$(pick_random_wallpaper)
  log "INFO" "Random theme + random wallpaper: $FINAL_WALLPAPER"
else
  SELECTION=$( (
    echo "🎲 Random"
    echo "$WALLPAPER_LIST"
  ) | rofi -dmenu -i -p "Select Wallpaper ($WALLPAPER_COUNT found)")

  [ -z "$SELECTION" ] && {
    log "INFO" "No wallpaper selected"
    exit 0
  }

  if [ "$SELECTION" = "🎲 Random" ]; then
    FINAL_WALLPAPER=$(pick_random_wallpaper)
    log "INFO" "Selected random wallpaper: $FINAL_WALLPAPER"
  else
    FINAL_WALLPAPER="$SELECTION"
    log "INFO" "Selected wallpaper: $FINAL_WALLPAPER"
  fi
fi

# Ensure absolute path
FINAL_WALLPAPER=$(realpath "$FINAL_WALLPAPER" 2>/dev/null || echo "$FINAL_WALLPAPER")
log "INFO" "Absolute path: $FINAL_WALLPAPER"

[ ! -f "$FINAL_WALLPAPER" ] && error "File not found: $FINAL_WALLPAPER"

# --- THEME GENERATION ---

log "INFO" "--- Starting Theme Update ---"
save_current "$FINAL_WALLPAPER"

# --- PYWAL-STYLE PREPROCESSING (OPTIONAL) ---
WALLPAPER_FOR_MATUGEN="$FINAL_WALLPAPER"

if [ "$PREPROCESS_FOR_PYWAL" = "true" ]; then
  log "INFO" "🎨 [Preprocessing] Creating pywal-style color extraction image..."
  TMP_WP="$HOME/.cache/hypr/matugen-input.png"
  mkdir -p "$(dirname "$TMP_WP")"
  
  # Try magick first, fall back to convert
  MAGICK_CMD=""
  if command -v magick >/dev/null 2>&1; then
    MAGICK_CMD="magick"
  elif command -v convert >/dev/null 2>&1; then
    MAGICK_CMD="convert"
  fi
  
  if [ -n "$MAGICK_CMD" ]; then
    log "VERBOSE" "Using $MAGICK_CMD to preprocess (resize=${PREPROCESS_SIZE}x${PREPROCESS_SIZE}, saturation=${PREPROCESS_SAT}%)"
    
    if $MAGICK_CMD "$FINAL_WALLPAPER" \
      -resize "${PREPROCESS_SIZE}x${PREPROCESS_SIZE}^" \
      -gravity center \
      -extent "${PREPROCESS_SIZE}x${PREPROCESS_SIZE}" \
      -modulate "100,${PREPROCESS_SAT},100" \
      "$TMP_WP" 2>>"$LOG_FILE"; then
      WALLPAPER_FOR_MATUGEN="$TMP_WP"
      log "INFO" "✓ Preprocessed wallpaper created: $WALLPAPER_FOR_MATUGEN"
    else
      log "WARNING" "Preprocessing failed, using original wallpaper"
    fi
  else
    log "WARNING" "ImageMagick not found, skipping preprocessing"
  fi
fi

log "INFO" "🎨 [Matugen] Generating Material Design 3 theme..."

# Use palette-style template so matugen fills the right color mapping (material or rainbow)
TMPL_STYLE="$QUICKSHELL_DIR/Colors.qml.tmpl.$PALETTE_STYLE"
TMPL_MAIN="$QUICKSHELL_DIR/Colors.qml.tmpl"
if [ -f "$TMPL_STYLE" ]; then
  cp "$TMPL_STYLE" "$TMPL_MAIN"
  log "VERBOSE" "Using palette template: Colors.qml.tmpl.$PALETTE_STYLE"
fi

# Normalize scheme name - add "scheme-" prefix if not present
MATUGEN_TYPE="$MATUGEN_SCHEME"
if [[ "$MATUGEN_TYPE" != scheme-* ]]; then
  MATUGEN_TYPE="scheme-$MATUGEN_TYPE"
fi

log "INFO" "Using scheme type: $MATUGEN_TYPE (mode: $MATUGEN_MODE)"
log "INFO" "Image file: $WALLPAPER_FOR_MATUGEN"

# Build matugen command using array (safer than eval)
MATUGEN_CMD=(matugen image "$WALLPAPER_FOR_MATUGEN")

# Add mode (light/dark)
MATUGEN_CMD+=(--mode "$MATUGEN_MODE")

# Add scheme type
MATUGEN_CMD+=(--type "$MATUGEN_TYPE")

# Add resize filter for better color extraction
MATUGEN_CMD+=(--resize-filter "$MATUGEN_RESIZE_FILTER")

# Add contrast (helps distinguish colors between wallpapers)
if [ -n "$MATUGEN_CONTRAST" ] && [ "$MATUGEN_CONTRAST" != "0" ] && [ "$MATUGEN_CONTRAST" != "0.0" ]; then
  MATUGEN_CMD+=(--contrast "$MATUGEN_CONTRAST")
  log "VERBOSE" "Using contrast: $MATUGEN_CONTRAST"
fi

# Add config file if it exists (expand ~ to $HOME on path lines only; matugen does not expand tilde)
MATUGEN_CONFIG_FINAL=""
if [ -f "$MATUGEN_CONFIG" ]; then
  MATUGEN_CONFIG_EXPANDED="${MATUGEN_CONFIG_EXPANDED:-$HOME/.cache/hypr/matugen-config-expanded.toml}"
  mkdir -p "$(dirname "$MATUGEN_CONFIG_EXPANDED")"
  sed '/input_path\s*=\|output_path\s*=/ s|"~|"'$HOME'|g' "$MATUGEN_CONFIG" > "$MATUGEN_CONFIG_EXPANDED"
  MATUGEN_CONFIG_FINAL="$MATUGEN_CONFIG_EXPANDED"
  MATUGEN_CMD+=(--config "$MATUGEN_CONFIG_FINAL")
  log "VERBOSE" "Using matugen config: $MATUGEN_CONFIG (expanded to $MATUGEN_CONFIG_FINAL)"
  # Create output directories so matugen can write configs (e.g. ~/.config/kitty/themes, ~/.config/rofi, ...)
  while IFS= read -r outpath; do
    [ -z "$outpath" ] && continue
    outpath="${outpath/#\~/$HOME}"
    outdir="$(dirname "$outpath")"
    if [ -n "$outdir" ] && [ "$outdir" != "." ]; then
      mkdir -p "$outdir"
      log "VERBOSE" "Ensured output dir: $outdir"
    fi
  done < <(sed -n 's/^[[:space:]]*output_path[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$MATUGEN_CONFIG_EXPANDED")
else
  log "WARNING" "No matugen config found at $MATUGEN_CONFIG - templates will not be generated"
fi

# Add verbose flag if enabled
if [ "$VERBOSE" = "true" ]; then
  MATUGEN_CMD+=(--verbose)
else
  MATUGEN_CMD+=(--quiet)
fi

# Add show-colors flag if enabled
if [ "$MATUGEN_SHOW_COLORS" = "true" ]; then
  MATUGEN_CMD+=(--show-colors)
fi

# Add dry-run flag if enabled (for testing)
if [ "$MATUGEN_DRY_RUN" = "true" ]; then
  MATUGEN_CMD+=(--dry-run)
  log "INFO" "DRY RUN MODE - No actual changes will be made"
fi

log "INFO" "Running: ${MATUGEN_CMD[*]}"

# Run matugen and capture output
run_matugen() {
  local -a cmd=("${MATUGEN_CMD[@]}")
  local out
  out=$("${cmd[@]}" 2>&1) || return_code=$?
  return_code=${return_code:-0}
  printf "%s" "$out"
  return "$return_code"
}

MATUGEN_OUTPUT="$(run_matugen)" || MATUGEN_EXIT=$?
MATUGEN_EXIT=${MATUGEN_EXIT:-0}

if [ "$MATUGEN_EXIT" -ne 0 ]; then
  # If config/templates failed (e.g. missing matugen-themes input files), retry with Quickshell-only config
  if echo "$MATUGEN_OUTPUT" | grep -qiE "Failed to read config file|Failed to get the input and output paths"; then
    MATUGEN_MINIMAL_CONF="$HOME/.cache/hypr/matugen-config-minimal.toml"
    mkdir -p "$(dirname "$MATUGEN_MINIMAL_CONF")"
    QUICKSHELL_TMPL="$QUICKSHELL_DIR/Colors.qml.tmpl"
    if [ -f "$QUICKSHELL_TMPL" ]; then
      log "WARNING" "Matugen config/templates failed (missing input files?). Retrying with Quickshell-only config."
      {
        echo '[config]'
        echo '[templates.quickshell_theme]'
        printf 'input_path = "%s/Colors.qml.tmpl"\n' "$QUICKSHELL_DIR"
        printf 'output_path = "%s/Colors.qml"\n' "$QUICKSHELL_DIR"
      } > "$MATUGEN_MINIMAL_CONF"
      MATUGEN_CMD_RETRY=()
      skip_next=false
      for tok in "${MATUGEN_CMD[@]}"; do
        if $skip_next; then
          skip_next=false
          continue
        fi
        if [ "$tok" = "--config" ] || [ "$tok" = "-c" ]; then
          MATUGEN_CMD_RETRY+=(--config "$MATUGEN_MINIMAL_CONF")
          skip_next=true
          continue
        fi
        MATUGEN_CMD_RETRY+=("$tok")
      done
      # If original command had no config, retry command won't have one either; add minimal
      if ! printf '%s\n' "${MATUGEN_CMD_RETRY[@]}" | grep -qx -- "--config"; then
        MATUGEN_CMD_RETRY+=(--config "$MATUGEN_MINIMAL_CONF")
      fi
      log "INFO" "Retry command: ${MATUGEN_CMD_RETRY[*]}"
      MATUGEN_OUTPUT="$("${MATUGEN_CMD_RETRY[@]}" 2>&1)" || MATUGEN_EXIT=$?
      MATUGEN_EXIT=${MATUGEN_EXIT:-0}
      if [ "$MATUGEN_EXIT" -eq 0 ]; then
        log "INFO" "Quickshell theme generated. For Hyprland/Kitty/etc. run: git clone https://github.com/InioX/matugen-themes.git ~/.config/matugen-themes"
      fi
    fi
  fi
fi

if [ "$MATUGEN_EXIT" -ne 0 ]; then
  log "ERROR" "Matugen failed to generate theme (exit=$MATUGEN_EXIT)"
  log "ERROR" "Matugen output: $MATUGEN_OUTPUT"
  error "Failed to generate theme with matugen. See log for details: $LOG_FILE"
else
  log "INFO" "✓ Matugen theme generated successfully"
  if [ "$VERBOSE" = "true" ] && [ -n "$MATUGEN_OUTPUT" ]; then
    log "VERBOSE" "Matugen output: $MATUGEN_OUTPUT"
  fi

  # Extract and log the source color for debugging
  SOURCE_COLOR=$(matugen image "$WALLPAPER_FOR_MATUGEN" --mode "$MATUGEN_MODE" --type "$MATUGEN_TYPE" --json hex 2>/dev/null | grep -o '"source_color"[^}]*' | head -1 || echo "unknown")
  log "INFO" "Extracted source color: $SOURCE_COLOR"
fi

# --- GENERATE HIGH CONTRAST TEXT COLORS ---
if [ "$GENERATE_HIGH_CONTRAST_TEXT" = "true" ]; then
  log "INFO" "🎨 [Text Colors] Generating high-contrast text colors..."
  
  # Extract background color from generated theme
  BG_COLOR=""
  if [ -f "$HOME/.config/hypr/matugen-colors.conf" ]; then
    BG_COLOR=$(grep "md3_background" "$HOME/.config/hypr/matugen-colors.conf" | head -1 | grep -oP 'rgba\(\K[0-9a-fA-F]{6}' || echo "")
  fi
  
  # Fallback: try to extract from matugen JSON output
  if [ -z "$BG_COLOR" ]; then
    BG_COLOR=$(matugen image "$WALLPAPER_FOR_MATUGEN" --mode "$MATUGEN_MODE" --type "$MATUGEN_TYPE" --json hex 2>/dev/null | grep -oP '"background".*?"hex":\s*"\K#[0-9a-fA-F]{6}' | head -1 || echo "")
  fi
  
  # Final fallback based on mode
  if [ -z "$BG_COLOR" ]; then
    if [ "$MATUGEN_MODE" = "dark" ]; then
      BG_COLOR="#1a1a1a"
    else
      BG_COLOR="#f5f5f5"
    fi
    log "WARNING" "Could not extract background color, using fallback: $BG_COLOR"
  else
    log "INFO" "Detected background color: $BG_COLOR"
  fi
  
  # Generate contrast colors
  TEXT_PRIMARY=$(generate_contrast_text "$BG_COLOR")
  TEXT_SECONDARY=$(generate_accent_text "$BG_COLOR")
  
  log "INFO" "Generated text colors: primary=$TEXT_PRIMARY, secondary=$TEXT_SECONDARY"
  
  # Append to Hyprland colors
  if [ -f "$HOME/.config/hypr/matugen-colors.conf" ]; then
    {
      echo ""
      echo "# High-contrast text colors (auto-generated)"
      echo "\$md3_text_primary = rgba(${TEXT_PRIMARY#\#}ff)"
      echo "\$md3_text_secondary = rgba(${TEXT_SECONDARY#\#}ee)"
      echo "\$md3_text_high_contrast = rgba(${TEXT_PRIMARY#\#}ff)"
    } >> "$HOME/.config/hypr/matugen-colors.conf"
    log "INFO" "✓ Added high-contrast text colors to Hyprland config"
  fi
  
  # Append to Quickshell theme
  COLORS_QML="$QUICKSHELL_DIR/Colors.qml"
  if [ -f "$COLORS_QML" ]; then
    # Check if text colors already exist
    if ! grep -q "textPrimary" "$COLORS_QML"; then
      # Remove the closing brace, add properties, then close again
      sed -i '$ d' "$COLORS_QML"
      {
        echo ""
        echo "    // High-contrast text colors (auto-generated)"
        echo "    property color textPrimary: \"$TEXT_PRIMARY\""
        echo "    property color textSecondary: \"$TEXT_SECONDARY\""
        echo "    property color textHighContrast: \"$TEXT_PRIMARY\""
        echo "}"
      } >> "$COLORS_QML"
      log "INFO" "✓ Added high-contrast text colors to Quickshell theme"
    else
      # Update existing values
      sed -i "s/property color textPrimary:.*/property color textPrimary: \"$TEXT_PRIMARY\"/" "$COLORS_QML"
      sed -i "s/property color textSecondary:.*/property color textSecondary: \"$TEXT_SECONDARY\"/" "$COLORS_QML"
      sed -i "s/property color textHighContrast:.*/property color textHighContrast: \"$TEXT_PRIMARY\"/" "$COLORS_QML"
      log "INFO" "✓ Updated high-contrast text colors in Quickshell theme"
    fi
  fi
fi

# Verify generated files exist
if [ -f "$HOME/.config/hypr/matugen-colors.conf" ]; then
  log "INFO" "✓ Hyprland colors file generated"
  FIRST_COLOR=$(head -5 "$HOME/.config/hypr/matugen-colors.conf" | grep -m1 "md3_" || echo "unknown")
  log "INFO" "  Sample: $FIRST_COLOR"
else
  log "WARNING" "Hyprland colors file not found at $HOME/.config/hypr/matugen-colors.conf"
fi

COLORS_QML="$QUICKSHELL_DIR/Colors.qml"
if [ -f "$COLORS_QML" ]; then
  log "INFO" "✓ Quickshell colors file generated at $COLORS_QML"
  PRIMARY_LINE=$(grep 'property color.primary' "$COLORS_QML" 2>/dev/null | head -1 || echo "unknown")
  log "INFO" "  Sample: $PRIMARY_LINE"
else
  log "WARNING" "Quickshell colors file not found at $COLORS_QML"
fi

# --- WALLPAPER SETTING ---

if [ "$MATUGEN_DRY_RUN" != "true" ]; then
  log "INFO" "🖼️ [awww] Setting wallpaper..."
  TRANSITION_TYPE="${TRANSITION_TYPE:-any}"
  TRANSITION_FPS="${TRANSITION_FPS:-60}"

  if ! awww img "$FINAL_WALLPAPER" --transition-type "$TRANSITION_TYPE" --transition-fps "$TRANSITION_FPS" 2>>"$LOG_FILE"; then
    error "awww failed to set wallpaper: $FINAL_WALLPAPER"
  fi
  log "INFO" "✓ Wallpaper set successfully"
else
  log "INFO" "🖼️ [awww] Skipped (dry-run mode)"
fi

# --- QUICKSHELL INTEGRATION ---

if [ "$MATUGEN_DRY_RUN" != "true" ]; then
  log "VERBOSE" "Checking for Quickshell..."
  if command -v quickshell &>/dev/null; then
    if pgrep -x quickshell >/dev/null 2>&1; then
      log "INFO" "🔄 [Quickshell] Restarting to apply new theme..."
      killall quickshell 2>/dev/null || true
      sleep 0.3
    fi
    if ! pgrep -x quickshell >/dev/null 2>&1; then
      setsid quickshell >/tmp/quickshell.log 2>&1 </dev/null &
      sleep 0.5
      if pgrep -x quickshell >/dev/null; then
        log "INFO" "✓ Quickshell started with new theme"
      else
        log "WARNING" "Quickshell failed to start. Check /tmp/quickshell.log"
      fi
    fi
  else
    log "WARNING" "Quickshell command not found"
  fi
fi

# --- OTHER APP RELOADS ---

if [ "$MATUGEN_DRY_RUN" != "true" ]; then
  log "VERBOSE" "Checking for other applications to reload..."

  # Hyprland
  if command -v hyprctl &>/dev/null && pgrep -x Hyprland >/dev/null 2>&1; then
    log "VERBOSE" "Hyprland is running, checking if reload is needed..."
    HYPR_MATUGEN_CONF="$HOME/.config/hypr/matugen-colors.conf"
    if [ -f "$HYPR_MATUGEN_CONF" ]; then
      log "INFO" "Reloading Hyprland configuration..."
      hyprctl reload >/dev/null 2>&1 && log "INFO" "✓ Hyprland reloaded" || log "VERBOSE" "Hyprland reload skipped"
    fi
  fi

  # Kitty (check both common matugen output paths)
  if command -v kitty &>/dev/null && pgrep -x kitty >/dev/null 2>&1; then
    KITTY_MATUGEN_CONF="$HOME/.config/kitty/matugen-colors.conf"
    KITTY_THEMES_CONF="$HOME/.config/kitty/themes/Matugen.conf"
    if [ -f "$KITTY_MATUGEN_CONF" ] || [ -f "$KITTY_THEMES_CONF" ]; then
      log "INFO" "Reloading Kitty configuration..."
      killall -SIGUSR1 kitty 2>/dev/null && log "INFO" "✓ Kitty reloaded" || log "VERBOSE" "Kitty reload skipped"
    fi
  fi

  # Dunst
  if command -v dunst &>/dev/null && pgrep -x dunst >/dev/null 2>&1; then
    DUNST_MATUGEN_CONF="$HOME/.config/dunst/dunstrc"
    if [ -f "$DUNST_MATUGEN_CONF" ] && grep -q "matugen" "$DUNST_MATUGEN_CONF" 2>/dev/null; then
      log "INFO" "Reloading Dunst..."
      killall -SIGUSR2 dunst 2>/dev/null && log "INFO" "✓ Dunst reloaded" || log "VERBOSE" "Dunst reload skipped"
    fi
  fi

  # Rofi (no live reload; next launch uses new colors)
  if [ -f "$HOME/.config/rofi/colors.rasi" ]; then
    log "VERBOSE" "Rofi colors.rasi updated (reload on next open)"
  fi

  # GTK 3/4: nudge apps to pick up new colors (restart or new windows for full effect)
  if [ -f "$HOME/.config/gtk-3.0/colors.css" ] || [ -f "$HOME/.config/gtk-4.0/colors.css" ]; then
    if command -v gsettings &>/dev/null; then
      gsettings set org.gnome.desktop.interface gtk-theme "" 2>/dev/null || true
      gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark" 2>/dev/null || true
      log "VERBOSE" "GTK colors updated (new app windows use new theme)"
    fi
  fi

  # Btop
  if command -v btop &>/dev/null && pgrep -x btop >/dev/null 2>&1; then
    if [ -f "$HOME/.config/btop/themes/matugen.theme" ]; then
      pkill -USR2 btop 2>/dev/null && log "INFO" "✓ Btop reloaded" || true
    fi
  fi

  # WezTerm (touch config so it reloads on next focus if reload_interval set)
  if [ -f "$HOME/.config/wezterm/colors/matugen_theme.toml" ] && [ -f "$HOME/.config/wezterm/wezterm.lua" ]; then
    touch "$HOME/.config/wezterm/wezterm.lua" 2>/dev/null && log "VERBOSE" "WezTerm theme file updated"
  fi
fi

log "INFO" "✅ Theme updated successfully!"
WALLPAPER_NAME=$(basename "$FINAL_WALLPAPER")
if [ "$MATUGEN_DRY_RUN" = "true" ]; then
  notify-send -u low "Wallpaper Script" "Dry run completed: $WALLPAPER_NAME" 2>/dev/null || true
else
  notify-send -u low "Wallpaper Changed" "Theme: $THEME_STYLE | $WALLPAPER_NAME" 2>/dev/null || true
fi