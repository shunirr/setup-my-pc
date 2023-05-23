# shellcheck shell=bash
if [ "$(uname)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
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
  command -v fenv >/dev/null || export PATH="$FENV_ROOT/bin:$PATH"
  eval "$(fenv init -)"
fi

if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix)/etc/bash_completion"
fi
if [ -f "$(brew --prefix)/opt/asdf/asdf.sh" ]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix)/opt/asdf/asdf.sh"
fi
if [ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix asdf)/libexec/asdf.sh"
fi
if [ -f "$HOME/.asdf/plugins/java/set-java-home.bash" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.asdf/plugins/java/set-java-home.bash"
fi

export LANG="ja_JP.UTF-8"
export LC_COLLATE="ja_JP.UTF-8"
export LC_CTYPE="ja_JP.UTF-8"
export LC_MESSAGES="ja_JP.UTF-8"
export LC_MONETARY="ja_JP.UTF-8"
export LC_NUMERIC="ja_JP.UTF-8"
export LC_TIME="ja_JP.UTF-8"
export LC_ALL=

# shellcheck disable=SC1091
source "$HOME/.bashrc"
