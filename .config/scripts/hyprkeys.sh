#!/bin/bash
# Shortcut cheat sheet for Hyprland

CATEGORY=""
PENDING_COMMENT=""
CONFIG_FILE="$HOME/.config/hypr/binds.conf"

while IFS= read -r line; do
  [[ -z "${line// /}" ]] && continue

  if [[ $line =~ ^#\ ---\ (.*)\ --- ]]; then
    CATEGORY="${BASH_REMATCH[1]}"
    PENDING_COMMENT=""
    continue
  fi

  if [[ $line =~ ^#\ (.*) ]] && [[ ! $line =~ ^#\ --- ]]; then
    PENDING_COMMENT="${BASH_REMATCH[1]}"
    continue
  fi

  if [[ $line =~ ^bind[elmnrs]*\ =\ (.*) ]]; then
    content="${BASH_REMATCH[1]}"

    inline_comment=""
    if [[ $line =~ \#\ (.*) ]]; then
      inline_comment="${BASH_REMATCH[1]}"
    fi

    IFS=',' read -r mod key action rest <<<"$content"

    pretty_keys=$(echo "$mod + $key" | sed 's/\$mainMod/Super/g; s/SUPER/Super/g; s/CTRL/Ctrl/g; s/ALT/Alt/g; s/SHIFT/Shift/g; s/  */ /g' | xargs)

    if [[ -n "$inline_comment" ]]; then
      description="$inline_comment"
    elif [[ -n "$PENDING_COMMENT" ]]; then
      description="$PENDING_COMMENT"
    else
      description=$(echo "$action" | xargs)
    fi

    printf "%-16s  %-24s  %s\n" "$CATEGORY" "$pretty_keys" "$description"
    PENDING_COMMENT=""
  else
    PENDING_COMMENT=""
  fi
done <"$CONFIG_FILE" | rofi -dmenu -i -p "Shortcuts" \
  -theme-str 'window { width: 55%; } listview { lines: 20; } element { font: "JetBrainsMono Nerd Font 12"; }'
