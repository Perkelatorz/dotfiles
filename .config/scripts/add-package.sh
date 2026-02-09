#!/bin/bash
# Quick package list manager - adds installed packages to yadm package lists.
# Usage: add-package.sh (or bind to a key in Hyprland)

set -euo pipefail

PKG_DIR="$HOME/.config/yadm/packages"

# Get installed packages
get_installed_packages() {
  local source="$1"

  if [[ "$source" == "pacman" ]]; then
    # Get installed pacman packages (native packages only, exclude AUR)
    # pacman -Qn shows only native packages (from official repos)
    pacman -Qn 2>/dev/null | awk '{print $1}' | sort
  else
    # Get installed AUR packages
    if command -v paru &>/dev/null; then
      paru -Qm 2>/dev/null | awk '{print $1}' | sort
    elif command -v yay &>/dev/null; then
      yay -Qm 2>/dev/null | awk '{print $1}' | sort
    else
      # Fallback: packages not in official repos
      # Get all packages and filter out native ones
      comm -23 <(pacman -Q | awk '{print $1}' | sort) \
        <(pacman -Qn | awk '{print $1}' | sort) 2>/dev/null
    fi
  fi
}

# Add package to list
add_to_list() {
  local pkg="$1"
  local list_file="$2"
  local target_file="$PKG_DIR/$list_file"
  local is_new_file=false

  # Validate package name
  if [[ -z "$pkg" ]] || [[ "$pkg" =~ [[:space:]] ]]; then
    notify-send "❌ Invalid Package" "Package name cannot be empty or contain spaces" -i error
    return 1
  fi

  # Create file if it doesn't exist
  if [[ ! -f "$target_file" ]]; then
    touch "$target_file"
    is_new_file=true
  fi

  # Check for duplicates
  if grep -Fxq "$pkg" "$target_file" 2>/dev/null; then
    notify-send "⚠️  Already in List" "$pkg already exists in $list_file" -i info
    return 0
  fi

  # Add package
  echo "$pkg" >>"$target_file"

  # If new file, add it to yadm
  if [[ "$is_new_file" == true ]]; then
    if command -v yadm &>/dev/null; then
      local yadm_root
      yadm_root=$(yadm rev-parse --show-toplevel 2>/dev/null || echo "")
      if [[ -n "$yadm_root" ]]; then
        local rel_path="${target_file#$yadm_root/}"
        yadm add "$rel_path" 2>/dev/null || true
        notify-send "✅ Added to List & YADM" "$pkg added to $list_file (tracked in yadm)" -i document-save
      else
        notify-send "✅ Added to List" "$pkg added to $list_file" -i document-save
      fi
    else
      notify-send "✅ Added to List" "$pkg added to $list_file" -i document-save
    fi
  else
    notify-send "✅ Added to List" "$pkg added to $list_file" -i document-save
  fi
}

# Main workflow
main() {
  if ! command -v rofi &>/dev/null; then
    notify-send "❌ Missing Dependency" "rofi is required" -i error
    exit 1
  fi

  # Step 1: Choose package source
  local source
  source=$(echo -e "pacman\nAUR" | rofi -dmenu -p "📦 Package Source" -i -no-custom)

  if [[ -z "$source" ]]; then
    exit 0
  fi

  # Step 2: Get and select from installed packages
  local package
  package=$(get_installed_packages "$source" |
    rofi -dmenu -p "Select installed $source package" -i -filter)

  if [[ -z "$package" ]]; then
    exit 0
  fi

  # Step 3: Select which list to add to
  local extension
  if [[ "$source" == "pacman" ]]; then
    extension=".pkgs"
  else
    extension=".aur"
  fi

  # Get available lists
  local list_files
  if [[ "$source" == "pacman" ]]; then
    list_files=$(find "$PKG_DIR" -name "*.pkgs" -printf "%f\n" | sort)
  else
    list_files=$(find "$PKG_DIR" -name "*.aur" -printf "%f\n" | sort)
  fi

  # Add option to create new file
  local selected_file
  selected_file=$(echo -e "$list_files\n➕ Create new file" |
    rofi -dmenu -p "Add '$package' to" -i -no-custom)

  if [[ -z "$selected_file" ]]; then
    exit 0
  fi

  # Handle new file creation
  if [[ "$selected_file" == "➕ Create new file" ]]; then
    local new_filename
    new_filename=$(rofi -dmenu -p "New filename (without extension)" -filter)

    if [[ -z "$new_filename" ]]; then
      exit 0
    fi

    # Remove extension if user added it
    new_filename="${new_filename%.pkgs}"
    new_filename="${new_filename%.aur}"
    selected_file="${new_filename}${extension}"
  fi

  # Add to selected list
  add_to_list "$package" "$selected_file"
}

main "$@"
