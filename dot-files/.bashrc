# shellcheck shell=bash
# shellcheck source=/dev/null
source "$(brew --prefix)/etc/bash_completion.d/git-prompt.sh"
# shellcheck source=/dev/null
source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"

export GIT_PS1_SHOWDIRTYSTATE=true
export PS1='[\u@\h \w]$(__git_ps1) '
export LSCOLORS=gxfxcxdxbxegedabagacad
alias ls="ls -F -G"

shopt -s globstar
shopt -s autocd

# Android SDK
export ANDROID_SDK=$HOME/Library/Android/sdk
export PATH="$PATH:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools"
if [ -d "$ANDROID_SDK/build-tools" ]; then
  LATEST_BUILD_TOOLS="$(find "$ANDROID_SDK/build-tools" -d -maxdepth 1 ! -name "build-tools" -print | sort -hr | head -1)"
  export PATH="$PATH:$LATEST_BUILD_TOOLS"
fi

# Dart
export PATH="$PATH:$HOME/.pub-cache/bin"
