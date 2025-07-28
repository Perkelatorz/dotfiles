#
# ~/.bashrc
#



# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export EDITOR='nvim'
export TERMINAL=kitty

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
