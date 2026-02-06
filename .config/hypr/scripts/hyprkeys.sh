#!/bin/bash

CONFIG_FILE="$HOME/.config/hypr/binds.conf"
CATEGORY="General"

while IFS= read -r line; do
  # 1. Update category if we hit a header
  if [[ $line =~ ^#\ ---\ (.*)\ --- ]]; then
    CATEGORY="${BASH_REMATCH[1]}"
    continue
  fi

  # 2. Match any bind (bind, bindel, bindm, etc.)
  if [[ $line =~ ^bind[elmnrs]*\ =\ (.*) ]]; then
    content="${BASH_REMATCH[1]}"

    # Split the line by commas
    IFS=',' read -r mod key action rest <<<"$content"

    # Clean up the modifier and key
    # Removes the 'SUPER' or '$mainMod' and formats nicely
    pretty_keys=$(echo "$mod + $key" | sed 's/\$mainMod/󰘳/g' | xargs)

    # Get description: either from the end of the line OR the action name
    if [[ $line =~ \#\ (.*) ]]; then
      description="${BASH_REMATCH[1]}"
    else
      description=$(echo "$action" | xargs) # Fallback to the command name
    fi

    # Output: [Category] Keybind | Description
    printf "[%-12s] %-15s │ %s\n" "$CATEGORY" "$pretty_keys" "$description"
  fi
done <"$CONFIG_FILE" | rofi -dmenu -i -p "󰌌 Shortcuts" \
  -theme-str 'window { width: 50%; } listview { lines: 15; } element { font: "JetBrainsMono Nerd Font 12"; }'
