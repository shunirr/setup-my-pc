if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi
if [ -f /usr/local/opt/asdf/asdf.sh ]; then
  . /usr/local/opt/asdf/asdf.sh
fi
if [ -f /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash ]; then
  . /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash
fi
if [ -f $HOME/.asdf/plugins/java/set-java-home.bash ]; then
  . $HOME/.asdf/plugins/java/set-java-home.bash
fi

export LANG="ja_JP.UTF-8"
export LC_COLLATE="ja_JP.UTF-8"
export LC_CTYPE="ja_JP.UTF-8"
export LC_MESSAGES="ja_JP.UTF-8"
export LC_MONETARY="ja_JP.UTF-8"
export LC_NUMERIC="ja_JP.UTF-8"
export LC_TIME="ja_JP.UTF-8"
export LC_ALL=

source ~/.bashrc

