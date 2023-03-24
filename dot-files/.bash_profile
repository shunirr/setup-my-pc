if [[ $(uname) == "Darwin" ]] && [[ $(uname -m) == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  . "$(brew --prefix)/etc/bash_completion"
fi
if [ -f "$(brew --prefix)/opt/asdf/asdf.sh" ]; then
  . "$(brew --prefix)/opt/asdf/asdf.sh"
fi
if [ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]; then
  . "$(brew --prefix asdf)/libexec/asdf.sh"
fi
if [ -f "$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" ]; then
  . "$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash"
fi
if [ -f "$(brew --prefix)/opt/asdf/etc/bash_completion.d/asdf.bash" ]; then
  . "$(brew --prefix)/opt/asdf/etc/bash_completion.d/asdf.bash"
fi
if [ -f "$HOME/.asdf/plugins/java/set-java-home.bash" ]; then
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

if [ -n "$(brew --prefix openssl)" ]; then
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=\"$(brew --prefix openssl)\" --with-readline-dir=\"$(brew --prefix readline)\""
fi

source ~/.bashrc

