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
# Show what you are choosing BETWEEN, not just a flat list of words: group-name
# splits matches by kind (commands vs. files vs. this script's own tags), and
# the descriptions format gives each group a header. fzf-tab only renders those
# headers when both are set -- without them, `pkgs add <TAB>` shows drift and
# every other installed package in one undifferentiated column.
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'

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

# ------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------
# `notes` / `nn` — the notes vault from the shell. Must come after compinit
# above; the file ends in a compdef.
[[ -r "$ZDOTDIR/notes.zsh" ]] && source "$ZDOTDIR/notes.zsh"
# `st` — syncthing status/pairing/conflicts without the web UI.
[[ -r "$ZDOTDIR/syncthing.zsh" ]] && source "$ZDOTDIR/syncthing.zsh"
# Completion for `pkgs` (~/.config/scripts/pkgs). No functions of its own —
# purely the compdef, so tab lists the subcommands and package lists.
[[ -r "$ZDOTDIR/pkgs.zsh" ]] && source "$ZDOTDIR/pkgs.zsh"

# NOTE: installers append `. "$HOME/.local/share/../bin/env"` here. That script
# only prepends $HOME/.local/share/../bin — the same directory .zprofile already
# puts on PATH as $HOME/.local/bin — so it just adds a second spelling of an
# existing entry. Deliberately not sourced; delete it again if an installer
# re-adds it.

# opencode. Guarded: .zshrc runs for every interactive shell, and an unguarded
# prepend stacks a fresh copy on PATH in each nested one.
case ":$PATH:" in
    *":$HOME/.opencode/bin:"*) ;;
    *) export PATH="$HOME/.opencode/bin:$PATH" ;;
esac

# nvm, from the Arch package rather than the upstream installer, so the init
# script lives under /usr/share instead of ~/.nvm. Defines the `nvm` function
# and puts the active node on PATH; without it `nvm` is simply not a command.
#
# Guarded: .zshrc is sourced by every interactive shell, including on a machine
# that hasn't been bootstrapped yet. An unguarded source of a missing file makes
# zsh print a "no such file or directory" error on EVERY prompt, which is what a
# fresh install looks like before packages/dev.pkgs lands the nvm package.
# Without nvm the system node from /usr/bin still works; only `nvm` is missing.
[[ -r /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh

# --- audiobooks -------------------------------------------------------------
# Find a book under ~/books and print its path. `book python` pre-narrows the
# list; filenames run words together, so match on the path instead.
book() {
  find ~/books -type f \( -iname '*.epub' -o -iname '*.pdf' \) -ipath "*${1:-}*" |
    fzf --height 40% --reverse --delimiter / --with-nth -2,-1 --prompt 'book> '
}

# Pick a book and turn it into an audiobook. Extra args go to autiobook.
abook() {
  local f
  f=$(book "$1") || return
  [[ -n $f ]] || return
  echo "converting: ${f:t}"
  autiobook "$f" "${@:2}"
}

# Browse Kokoro voices, hear them, and set the default.
#   ctrl-p plays the highlighted voice, enter makes it the default.
#   `voice regen` re-renders the samples (e.g. after changing speed).
voice() {
  local dir=~/audiobooks/samples
  local cfg=~/.config/autiobooks/config.toml

  if [[ $1 == regen || ! -d $dir || -z $(print -n $dir/*.wav(N)) ]]; then
    echo "rendering voice samples..."
    autiobook --sample "When you call the compile function, Python returns a pattern object. You can then use its search method to scan a string for the first match, or findall to collect every match at once." \
      --voice "${2:-best}" -o $dir >/dev/null 2>&1 || { echo "sample render failed"; return 1 }
  fi

  local pick
  pick=$(print -l $dir/*.wav(N) |
    fzf --height 50% --reverse --prompt 'voice> ' --delimiter / --with-nth -1 \
        --header 'ctrl-p play   enter set as default' \
        --bind 'ctrl-p:execute-silent(mpv --no-video --really-quiet {} >/dev/null 2>&1 &)' \
        --preview 'autiobook --list-voices | grep -i -- "$(basename {} .wav)"' \
        --preview-window 'down,3') || return

  [[ -n $pick ]] || return
  local v=${${pick:t}:r}

  if [[ -f $cfg ]] && grep -q '^voice *=' $cfg; then
    sed -i "s|^voice *=.*|voice = \"$v\"|" $cfg
    echo "default voice is now $v  ($cfg)"
  else
    echo "set this in $cfg:  voice = \"$v\""
  fi
}

# Machine-local overrides / secrets (untracked; see gitignore "Local secrets").
# Last, so a box can override anything set above it.
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
