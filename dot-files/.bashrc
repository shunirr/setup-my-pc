# shellcheck shell=bash

export GIT_PS1_SHOWDIRTYSTATE=true
export PS1='[\u@\h \w]$(__git_ps1) '
export LSCOLORS=gxfxcxdxbxegedabagacad

shopt -s globstar
shopt -s autocd

# Modern CLI aliases
if type eza >/dev/null 2>&1; then
  alias ls="eza --icons --git"
  alias ll="eza -l --icons --git"
  alias la="eza -la --icons --git"
  alias tree="eza --tree --icons"
else
  alias ls="ls -F -G"
  alias ll="ls -lF -G"
  alias la="ls -laF -G"
fi

if type bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
fi

if type fd >/dev/null 2>&1; then
  alias find="fd"
fi

if type rg >/dev/null 2>&1; then
  alias grep="rg"
fi
