#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

EDITOR=/usr/bin/nvim
TERMINAL=/usr/bin/kitty
export SOPS_AGE_KEY_FILE=$HOME/.sops/keys.txt
export SOPS_PUBLIC=$HOME/.sops/public.txt

parse_git_branch() { 
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1='[\[\e[38;5;134m\]\u\[\e[0m\]@\[\e[38;5;28m\]\h\[\e[0m\]]\[\e[38;5;33m\]\w\[\e[38;5;167m\]$(parse_git_branch)\[\e[0m\] \$ '

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias s='kitten ssh'
alias sopse='sops -e -a $(cat $SOPS_PUBLIC) -i'
alias sopsd='sops -d -a $(cat $SOPS_PUBLIC) -i'
