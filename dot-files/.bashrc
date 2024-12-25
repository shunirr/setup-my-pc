# shellcheck shell=bash

export GIT_PS1_SHOWDIRTYSTATE=true
export PS1='[\u@\h \w]$(__git_ps1) '
export LSCOLORS=gxfxcxdxbxegedabagacad
alias ls="ls -F -G"

shopt -s globstar
shopt -s autocd