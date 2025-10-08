# History settings
export HISTFILE="$ZDOTDIR/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Completion
export ZSH_COMPDUMP="$ZDOTDIR/.zcompdump"
autoload -Uz compinit && compinit -C
compinit

# Prompt (simple)
PROMPT='%n@%m:%~ %# '

# Aliases (examples)
# Colorize ls by default
alias ls='ls --color=auto'        # GNU ls (Linux)
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias ssh='kitten ssh'
