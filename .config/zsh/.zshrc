# Interactive zsh. Environment/PATH live in .zprofile — keep this file UX-only.

# ------------------------------------------------------------------
# zinit (plugin manager; auto-installs itself)
# ------------------------------------------------------------------
ZINIT_HOME="${ZDOTDIR:-$HOME}/.zinit"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# ------------------------------------------------------------------
# History
# ------------------------------------------------------------------
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS
setopt SHARE_HISTORY INC_APPEND_HISTORY

# ------------------------------------------------------------------
# Completion
# ------------------------------------------------------------------
zinit light zsh-users/zsh-completions
autoload -Uz compinit && compinit -C
zinit cdreplay -q
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' menu no                          # fzf-tab draws the menu

# ------------------------------------------------------------------
# Plugins
# ------------------------------------------------------------------
# fzf-tab must load after compinit but before widget-wrapping plugins.
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

# vi mode — initializes at first prompt and re-binds keys; anything that must
# survive it belongs in zvm_after_init below.
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

zvm_after_init() {
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    # fzf: Ctrl-R fuzzy history, Ctrl-T files, Alt-C cd into dir
    [[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
    [[ -r /usr/share/fzf/completion.zsh   ]] && source /usr/share/fzf/completion.zsh
}

# Must load last.
zinit light zsh-users/zsh-syntax-highlighting

# Directory previews when completing cd/z targets.
zstyle ':fzf-tab:complete:(cd|z|zoxide):*' fzf-preview 'eza -1 --color=always $realpath'

# ------------------------------------------------------------------
# Prompt + smart cd (each no-ops if the tool is missing)
# ------------------------------------------------------------------
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v zoxide   &>/dev/null && eval "$(zoxide init zsh)"

# ------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------
if command -v eza &>/dev/null; then
    alias ls='eza'
    alias ll='eza -la --git --icons=auto'
    alias la='eza -a'
    alias lt='eza --tree --level=2'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -A --color=auto'
fi
alias grep='grep --color=auto'
alias ssh='kitten ssh'
alias rvim='edit-in-kitty'
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
