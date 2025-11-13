# ------------------------------------------------------------------
# ZSH INTERACTIVE CONFIG (.zshrc)
#
# This file is for interactive settings (plugins, prompt, aliases).
# It loads *after* .zshenv.
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# ZINIT: PLUGIN MANAGER
# ------------------------------------------------------------------
# Define the zinit home directory, respecting $ZDOTDIR
ZINIT_HOME="${ZDOTDIR:-$HOME}/.zinit"

# Auto-install zinit if it's not already installed
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    echo "--- Installing zinit (auto-installer) ---"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    echo "--- zinit installation complete. ---"
fi

# Source zinit
source "$ZINIT_HOME/zinit.zsh"

# ------------------------------------------------------------------
# PLUGINS
# ------------------------------------------------------------------
zinit light "zsh-users/zsh-autosuggestions"
zinit light "zsh-users/zsh-history-substring-search"
zinit light "zsh-users/zsh-completions"


# vi mode
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# Syntax highlighting MUST be loaded last
zinit light "zsh-users/zsh-syntax-highlighting"

# ------------------------------------------------------------------
# ZSH: CORE INTERACTIVE CONFIGURATION
# ------------------------------------------------------------------

# History
# This correctly uses the $ZDOTDIR variable from .zshenv
export HISTFILE="$ZDOTDIR/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE appendhistory sharehistory incappendhistory histfindnodups

# Wal colors
(cat ~/.cache/wal/sequences &)

# Key Bindings for history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ------------------------------------------------------------------
# Completion
# ------------------------------------------------------------------
autoload -Uz compinit
compinit -C

# ------------------------------------------------------------------
# Prompt
# ------------------------------------------------------------------
# 1. Load vcs_info and enable PROMPT_SUBST
# PROMPT_SUBST is needed to expand the ${vcs_info_msg_0_} variable
autoload -Uz vcs_info
setopt PROMPT_SUBST

# 2. Set up the vcs_info hook to run before each prompt
precmd() {
  vcs_info
}

# 3. Configure vcs_info formatting (with colors)
# This sets what to show in different git states.
# %F{2} = Green, %F{3} = Yellow, %F{1} = Red
zstyle ':vcs_info:*' formats       '%F{2}(%b)%f'
zstyle ':vcs_info:*:staged:*'   formats       '%F{3}(%b %S)%f' # %S = 'staged'
zstyle ':vcs_info:*:unstaged:*' formats       '%F{1}(%b %U)%f' # %U = 'unstaged'
zstyle ':vcs_info:*' actionformats '%F{2}(%b|%a)%f'

# 4. Define the Left Prompt (PROMPT)
# %B%F{3} = Bold Yellow
# %F{8}   = Grey (bright black)
# %B%F{4} = Bold Blue
# %B%F{6} = Bold Cyan
# %B%#%b = Bold prompt symbol (% or #)
PROMPT='%B%F{3}%n%f%b%F{8}@%f%B%F{4}%m%f%b%F{8}:%f%B%F{6}%~%f%b %B%#%b '

# 5. Define the Right Prompt (RPROMPT)
# This will display the git info from vcs_info
RPROMPT='${vcs_info_msg_0_}'



ZVM_SYSTEM_CLIPBOARD_ENABLED=true



# ------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias ssh='kitten ssh'
alias rvim='edit-in-kitty'
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
