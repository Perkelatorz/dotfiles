# set session-wide environment (LANG, EDITOR, etc.)
export LANG=en_US.UTF-8
export EDITOR=nvim


# Supported applications should follow these rules if they are an option
# Set XDG base directories (if not already set by system)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Ensure base directories exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

# Set common app paths to use XDG (login shells & GUI apps)
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

# Ensure subdirs exist for apps that don't auto-create
mkdir -p "${GNUPGHOME}" "${PASSWORD_STORE_DIR}" "$(dirname "$LESSHISTFILE")" "$(dirname "$HISTFILE")"

# start user agents (ssh-agent, gpg-agent) if not already running
# [ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)"
# [ -z "$GPG_AGENT_INFO" ] && gpg-agent --daemon > /dev/null 2>&1

export PATH="$PATH:${HOME}/.local/bin"


# Partial Supported Apps and common tools
export ANSIBLE_HOME="${XDG_CONFIG_HOME}/ansible"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME}/ansible.cfg"
export ANSIBLE_GALAXY_CACHE_DIR="${XDG_CACHE_HOME}/ansible/galaxy_cache"
export ASPELL_CONF="per-conf $XDG_CONFIG_HOME/aspell/aspell.conf; personal $XDG_DATA_HOME/aspell/en.pws; repl $XDG_DATA_HOME/aspell/en.prepl"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
export BITWARDEN_SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/.bitwarden-ssh-agent.sock"
export SSH_AUTH_SOCK="$BITWARDEN_SSH_AUTH_SOCK"
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export DISCORD_USER_DATA_DIR="${XDG_DATA_HOME}"
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export FFMPEG_DATADIR="$XDG_CONFIG_HOME"/ffmpeg
export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc":"$XDG_CONFIG_HOME/gtk-2.0/gtkrc.mine"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
export MYSQL_HISTFILE="$XDG_STATE_HOME/mysql_history"
export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME/python-eggs"
export RUFF_CACHE_DIR=$XDG_CACHE_HOME/ruff
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
export XSERVERRC="$XDG_CONFIG_HOME"/X11/xserverrc

