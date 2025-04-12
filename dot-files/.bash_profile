# shellcheck shell=bash
if [ "$(uname)" = "Darwin" ]; then
  if  [ "$(uname -m)" = "arm64" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

export PATH="$PATH:$HOME/.docker/bin"
# Android SDK
export ANDROID_SDK=$HOME/Library/Android/sdk
export PATH="$PATH:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools"
if [ -d "$ANDROID_SDK/build-tools" ]; then
  LATEST_BUILD_TOOLS="$(find "$ANDROID_SDK/build-tools" -d -maxdepth 1 ! -name "build-tools" -print | sort -hr | head -1)"
  export PATH="$PATH:$LATEST_BUILD_TOOLS"
fi

# Dart
export PATH="$PATH:$HOME/.pub-cache/bin"

# FENV
export FENV_ROOT="$HOME/.fenv"
if [ -d "$FENV_ROOT" ]; then
  export PATH="$FENV_ROOT/bin:$PATH"
  eval "$(fenv init -)"
fi

if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix)/etc/bash_completion"
fi

# MISE
if [ -f "$HOME/.local/bin/mise" ]; then
  eval "$($HOME/.local/bin/mise activate bash)"
fi

# uv
# shellcheck source=/dev/null
source "$HOME/.local/bin/env"

export LANG="ja_JP.UTF-8"
export LC_COLLATE="ja_JP.UTF-8"
export LC_CTYPE="ja_JP.UTF-8"
export LC_MESSAGES="ja_JP.UTF-8"
export LC_MONETARY="ja_JP.UTF-8"
export LC_NUMERIC="ja_JP.UTF-8"
export LC_TIME="ja_JP.UTF-8"
export LC_ALL=

# shellcheck source=/dev/null
source "$HOME/.bashrc"
