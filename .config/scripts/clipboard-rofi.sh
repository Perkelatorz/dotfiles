#!/bin/bash
# Enhanced clipboard manager using cliphist + rofi
# Usage: clipboard-rofi.sh [--text|--images|--all]

MODE="${1:---all}"
THUMB_DIR="${XDG_RUNTIME_DIR:-/tmp}/cliphist-thumbs"
mkdir -p "$THUMB_DIR"

paste_selection() {
    echo "$1" | cliphist decode | wl-copy
}

show_text() {
    local selected
    selected=$(cliphist list | grep -v '^\[[[:space:]]*binary' | rofi -dmenu -i -p "Clipboard (text)" \
        -theme-str 'window { width: 50%; } listview { lines: 15; }')
    [ -n "$selected" ] && paste_selection "$selected"
}

show_images() {
    rm -f "$THUMB_DIR"/thumb_*.png

    local entries=()
    local idx=0

    while IFS= read -r line; do
        if [[ "$line" == *"binary"* ]] || [[ "$line" == *"[["*"]]"* ]]; then
            local id="${line%%	*}"
            local thumb="$THUMB_DIR/thumb_${idx}.png"
            echo "$line" | cliphist decode > "$thumb" 2>/dev/null
            if file "$thumb" | grep -qiE 'image|png|jpeg|gif|webp|bitmap'; then
                entries+=("$line")
                idx=$((idx + 1))
            else
                rm -f "$thumb"
            fi
        fi
    done < <(cliphist list)

    if [ ${#entries[@]} -eq 0 ]; then
        rofi -e "No images in clipboard history"
        return
    fi

    local display=""
    for i in "${!entries[@]}"; do
        local thumb="$THUMB_DIR/thumb_${i}.png"
        if [ -f "$thumb" ]; then
            display+="${entries[$i]}\x00icon\x1f${thumb}\n"
        else
            display+="${entries[$i]}\n"
        fi
    done

    local selected
    selected=$(echo -en "$display" | rofi -dmenu -i -p "Clipboard (images)" \
        -show-icons \
        -theme-str 'window { width: 50%; } listview { lines: 8; } element-icon { size: 64px; }')
    [ -n "$selected" ] && paste_selection "$selected"
}

show_all() {
    local selected
    selected=$(cliphist list | rofi -dmenu -i -p "Clipboard" \
        -theme-str 'window { width: 50%; } listview { lines: 15; }')
    [ -n "$selected" ] && paste_selection "$selected"
}

case "$MODE" in
    --text)   show_text ;;
    --images) show_images ;;
    --all)    show_all ;;
    *)        show_all ;;
esac
