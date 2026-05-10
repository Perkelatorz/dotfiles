#!/usr/bin/env bash
# Remove Neovim *data* installs so the next Nvim start reinstalls vim.pack plugins,
# Mason (LSP + tools), and Tree-sitter parsers (see DEPENDENCIES.md).
#
# Usage:
#   ./scripts/reset-nvim-data.sh              # prompt for confirmation
#   ./scripts/reset-nvim-data.sh --yes      # non-interactive
#   ./scripts/reset-nvim-data.sh --yes --reset-lock   # also delete nvim-pack-lock.json
#
# Does NOT remove: your config (~/.config/nvim), spell files, shada, or project code.
# OS packages (git, gcc, tree-sitter, …) come from yadm — see ~/.config/yadm/packages/core.pkgs

set -euo pipefail

NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
NVIM_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
NVIM_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
NVIM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

YES=0
RESET_LOCK=0
for arg in "$@"; do
	case "$arg" in
	--yes) YES=1 ;;
	--reset-lock) RESET_LOCK=1 ;;
	-h | --help)
		head -n 15 "$0" | tail -n +2
		exit 0
		;;
	esac
done

echo "Neovim data reset"
echo "  DATA   = $NVIM_DATA   (mason/, site/ = pack plugins + treesitter)"
echo "  CACHE  = $NVIM_CACHE  (all nvim cache — optional but recommended for clean TS builds)"
echo "  STATE  = $NVIM_STATE  (log only: nvim-pack.log if present)"
if [[ "$RESET_LOCK" -eq 1 ]]; then
	echo "  LOCK   = $NVIM_CONFIG/nvim-pack-lock.json  (WILL BE DELETED — next start re-resolves plugin SHAs)"
else
	echo "  LOCK   = kept (same plugin commits from lockfile after reinstall)"
fi

if [[ "$YES" != 1 ]]; then
	read -r -p "Delete the above? [y/N] " a
	[[ "${a,,}" == "y" ]] || {
		echo "Aborted."
		exit 1
	}
fi

rm -rf "$NVIM_DATA/mason" "$NVIM_DATA/site"
rm -rf "$NVIM_CACHE"

# Pack / Mason log (optional)
if [[ -d "$NVIM_STATE/log" ]]; then
	rm -f "$NVIM_STATE/log/nvim-pack.log" 2>/dev/null || true
fi

if [[ "$RESET_LOCK" -eq 1 ]] && [[ -f "$NVIM_CONFIG/nvim-pack-lock.json" ]]; then
	rm -f "$NVIM_CONFIG/nvim-pack-lock.json"
	echo "Removed nvim-pack-lock.json"
fi

echo "Done. Start Neovim once (or run: nvim +qa); vim.pack + Mason + Tree-sitter will repopulate data dirs."
