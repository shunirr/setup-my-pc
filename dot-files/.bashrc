source $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
source $(brew --prefix)/etc/bash_completion.d/git-completion.bash

GIT_PS1_SHOWDIRTYSTATE=true
export PS1='[\u@\h \w]$(__git_ps1) '
export LSCOLORS=gxfxcxdxbxegedabagacad
alias ls="ls -F -G"

shopt -s globstar
shopt -s autocd

# Android SDK
export ANDROID_SDK=$HOME/Library/Android/sdk
BUILD_TOOLS_VERSION="$(ls -1 $ANDROID_SDK/build-tools/ | sort -hr | head -1)"
export PATH="$PATH":"$ANDROID_SDK/tools":"$ANDROID_SDK/tools/bin":"$ANDROID_SDK/platform-tools":"$ANDROID_SDK/build-tools/$BUILD_TOOLS_VERSION"

# Dart
export PATH="$PATH":"$HOME/.pub-cache/bin"

