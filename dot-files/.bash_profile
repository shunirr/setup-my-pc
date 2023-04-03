# shellcheck shell=bash
if [ "$(uname)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
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
if [ -f "$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" ]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash"
fi
if [ -f "$(brew --prefix)/opt/asdf/etc/bash_completion.d/asdf.bash" ]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix)/opt/asdf/etc/bash_completion.d/asdf.bash"
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