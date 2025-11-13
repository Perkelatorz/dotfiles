# ------------------------------------------------------------------
# ZSH ENVIRONMENT (.zshenv)
#
# This file is for environment variables.
# It is loaded by ALL shells (interactive, non-interactive, scripts).
# ------------------------------------------------------------------

# Define ZDOTDIR (Zsh Dotfile Directory)
# This tells Zsh where to find your other config files (.zshrc, .zsh_history)

# ~/.zshenv  -- keep minimal!
# Prefer XDG_CONFIG_HOME if set, otherwise use ~/.config
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# If the directory doesn't exist, fall back to $HOME to avoid breakage
[ -d "$ZDOTDIR" ] || export ZDOTDIR="$HOME"


