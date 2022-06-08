source /usr/local/etc/bash_completion.d/git-prompt.sh
source /usr/local/etc/bash_completion.d/git-completion.bash

GIT_PS1_SHOWDIRTYSTATE=true
export PS1='\[\e[0;36;44m\][\u@\h \w]$(__git_ps1)\$\[\033[00m\] '
export LSCOLORS=gxfxcxdxbxegedabagacad
alias ls="ls -F -G"

shopt -s globstar
shopt -s autocd

# Android SDK
export ANDROID_SDK=$HOME/Library/Android/sdk
export PATH=$ANDROID_SDK/tools:$ANDROID_SDK/platform-tools:$ANDROID_SDK/build-tools/31.0.0:$PATH
