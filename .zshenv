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

# Bitwarden SSH agent — also set in .zprofile/environment.d, but those only
# cover login shells / the systemd session; this covers non-login shells
# (e.g. Claude Code's Bash tool). ssh falls back to ~/.ssh keys if absent.
# Bitwarden moved the socket from $XDG_RUNTIME_DIR to $HOME in a 2026-07 update;
# prefer whichever actually exists so the next move doesn't break us silently.
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
  for _bwsock in "$HOME/.bitwarden-ssh-agent.sock" "${XDG_RUNTIME_DIR:-/run/user/$UID}/.bitwarden-ssh-agent.sock"; do
    [ -S "$_bwsock" ] && export SSH_AUTH_SOCK="$_bwsock" && break
  done
  unset _bwsock
fi


