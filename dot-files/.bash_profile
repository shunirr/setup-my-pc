# shellcheck shell=bash
add_path() {
  if [[ "$PATH" == *"$1"* ]]; then
    export PATH="$PATH:$1"
  fi
}

if [ "$(uname)" = "Darwin" ]; then
  if  [ "$(uname -m)" = "arm64" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

add_path "$HOME/.docker/bin"
add_path "$HOME/.local/bin"

# Android SDK
export ANDROID_SDK=$HOME/Library/Android/sdk
add_path "$ANDROID_SDK/tools"
add_path "$ANDROID_SDK/tools/bin"
add_path "$ANDROID_SDK/platform-tools"
if [ -d "$ANDROID_SDK/build-tools" ]; then
  LATEST_BUILD_TOOLS="$(find "$ANDROID_SDK/build-tools" -d -maxdepth 1 ! -name "build-tools" -print | sort -hr | head -1)"
  add_path "$LATEST_BUILD_TOOLS"
fi

# Dart
add_path "$HOME/.pub-cache/bin"

# FENV
export FENV_ROOT="$HOME/.fenv"
if [ -d "$FENV_ROOT" ]; then
  add_path "$FENV_ROOT/bin"
  eval "$(fenv init -)"
fi

if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix)/etc/bash_completion"
fi


# MISE
if [ -f "$HOME/.local/bin/mise" ]; then
  eval "$("$HOME"/.local/bin/mise activate bash)"
fi

# uv
if [ -f "$HOME/.local/bin/uv" ]; then
  eval "$(uv generate-shell-completion bash)"
fi
if [ -f "$HOME/.local/bin/uvx" ]; then
  eval "$(uvx --generate-shell-completion bash)"
fi

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
