#!/bin/bash
# Shortcut cheat sheet. Reads whichever binds.conf belongs to the running
# compositor and renders it through rofi.
#
# Hyprland format:  bind = MOD, KEY, action, args   # trailing description
#                   sections marked  # --- Name ---
# Mango format:     bind=MOD,KEY,action,args
#                   description on the preceding # line
#                   sections marked by a # Name line between # ===== fences

# shellcheck source=/dev/null
. "$(dirname "$0")/_compositor.sh"

case "$COMPOSITOR" in
  mango) CONFIG_FILE="$HOME/.config/mango/binds.conf" ;;
  *)     CONFIG_FILE="$HOME/.config/hypr/binds.conf" ;;
esac

CATEGORY=""
PENDING_COMMENT=""
# Header state machine for the mango format:
#   0 = normal, 1 = just saw an opening fence (next # line is the title),
#   2 = just took a title (the following fence closes the header)
HDR=0

render() {
  while IFS= read -r line; do
    # A blank line ends a comment block, so a stale description can't leak
    # onto an unrelated bind further down.
    if [[ -z "${line// /}" ]]; then
      PENDING_COMMENT=""
      HDR=0
      continue
    fi

    # --- Hyprland section header:  # --- Name ---
    if [[ $line =~ ^#\ ---\ (.*)\ --- ]]; then
      CATEGORY="${BASH_REMATCH[1]}"
      PENDING_COMMENT=""
      continue
    fi

    # --- Mango section fence:  # =====...
    if [[ $line =~ ^#\ *=+$ ]]; then
      # Only the OPENING fence arms the title grab; the closing one must not,
      # or the first description below the header gets read as the section name.
      [[ $HDR -eq 2 ]] && HDR=0 || HDR=1
      PENDING_COMMENT=""
      continue
    fi

    if [[ $line =~ ^#\ (.*) ]]; then
      if [[ $HDR -eq 1 ]]; then
        CATEGORY="${BASH_REMATCH[1]}"
        HDR=2
      elif [[ -z "$PENDING_COMMENT" ]]; then
        # First line of a comment block is the description; continuation lines
        # are prose and get ignored.
        PENDING_COMMENT="${BASH_REMATCH[1]}"
      fi
      continue
    fi
    HDR=0

    # Hyprland "bind = ..." / mango "bind=..." / mousebind= / axisbind=
    if [[ $line =~ ^(bind|mousebind|axisbind)[elmnrsp]*[[:space:]]*=[[:space:]]*(.*) ]]; then
      content="${BASH_REMATCH[2]}"

      inline_comment=""
      if [[ $line =~ \#\ (.*) ]]; then
        inline_comment="${BASH_REMATCH[1]}"
        content="${content%%#*}"
      fi

      IFS=',' read -r mod key action _rest <<<"$content"

      pretty_keys=$(echo "$mod + $key" |
        sed 's/\$mainMod/Super/g; s/SUPER/Super/g; s/CTRL/Ctrl/g; s/ALT/Alt/g; s/SHIFT/Shift/g;
             s/NONE + //g; s/none + //g; s/+/ + /g; s/  */ /g' | xargs)

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
  done <"$CONFIG_FILE"
}

render | rofi -dmenu -i -p "Shortcuts" \
  -theme-str 'window { width: 55%; } listview { lines: 20; } element { font: "JetBrainsMono Nerd Font 12"; }'
