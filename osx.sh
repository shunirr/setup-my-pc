#!/usr/bin/env bash -eux

RUBY_VERSION="2.6.5"
NODE_VERSION="12.2.0"
JAVA_VERSION="oracle-17.0.1"
KOTLIN_VERSION="1.5.31"

wait_process() {
  sleep 5
  while true; do
    sleep 1
    set +e
    pgrep "$1" >/dev/null 2>&1
    if [[ $? != 0 ]]; then
      break
    fi
    set -e
  done
}

ssh_keygen() {
  expect -c "
  spawn ssh-keygen
  expect :\ ; send \n
  expect :\ ; send \n
  expect :\ ; send \n
  expect eof exit 0
  "
}

add_sudoers() {
  local ENTRY='%wheel ALL=(ALL) NOPASSWD: ALL'
  if [[ ! "$(sudo cat /etc/sudoers | grep '${ENTRY}')" ]]; then
    sudo sh -c "echo '${ENTRY}' >> /etc/sudoers"
  fi
}

join_wheel_group() {
  local USERNAME=$(who am i | cut -d" " -f1)
  if [[ ! "$(dscl . -read /Groups/wheel | grep ${USERNAME})" ]]; then
    sudo dscl . -append /Groups/wheel GroupMembership ${USERNAME}
  fi
}

install_command_line_developer_tools() {
  if [[ ! -d "/Library/Developer/CommandLineTools" ]]; then
    sh -c "xcode-select --install"
    wait_process "Command Line Developer Tools"
  fi
}

install_homebrew() {
  if [[ ! "$(brew --version)" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
}

homebrew_init() {
  install_homebrew
  brew update
  brew upgrade
}

brew_install() {
  if [[ ! -d /usr/local/Cellar/$1 ]]; then
    brew install $1
  fi
}

brew_cask_install() {
  if [[ ! -d /usr/local/Caskroom/$1 ]]; then
    brew install --cask $1
  fi
}

mas_install() {
  if [[ ! "$(mas list | grep $1)" ]]; then
    mas install $1
  fi
}

install_ricty() {
  if [[ ! "$(ls ~/Library/Fonts/Ricty*.ttf)" ]]; then
    brew tap sanemat/font
    brew_install ricty
    cp -f /usr/local/opt/ricty/share/fonts/Ricty*.ttf ~/Library/Fonts/
    fc-cache -vf
  fi
}

########

add_sudoers
join_wheel_group

[[ ! -d ~/.ssh ]] && ssh_keygen

UNAME="$(uname)"
UNAME_MACHINE="$(uname -m)"

# If AppleSilicon Mac
if [[ "$UNAME" == "Darwin" ]] && [[ "$UNAME_MACHINE" == "arm64" ]]; then
  # Install Rosetta2
  expect -c "
  spawn softwareupdate --install-rosetta
  expect :\ ; send A\n
  expect eof exit 0
  "

  # Re-launch install script by x86_64
  arch -arch x86_64 $0
  exit 0
fi

install_command_line_developer_tools

homebrew_init

brew_install mas

mas_install 497799835 # Xcode
sudo xcodebuild -license accept

brew_install git
brew_install tmux
brew_install wget
brew_install the_silver_searcher
brew_install jq

# Bash
brew_install bash
brew_install bash-completion

if [[ ! "$(cat /etc/shells | grep /usr/local/bin/bash)" ]]; then
  echo /usr/local/bin/bash | sudo tee -a /etc/shells
fi
if [[ "$(dscl localhost -read Local/Default/Users/$USER UserShell | cut -d' ' -f2)" != "/usr/local/bin/bash" ]]; then
  chsh -s /usr/local/bin/bash
fi

# asdf
brew_install asdf

# Copy dot-files
cp -v -R dot-files/. $HOME

[[ ! -f "$HOME/.bashrc_private" ]] && touch "$HOME/.bashrc_private"

# Load bashrc
source ~/.bashrc

# Ruby
if [[ ! $(asdf plugin list | grep ruby) ]]; then
  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
fi
if [[ ! $(asdf list ruby | grep "$RUBY_VERSION") ]]; then
  asdf install ruby "$RUBY_VERSION"
  asdf global ruby "$RUBY_VERSION"
fi
if [[ ! $(type bundle >/dev/null 2>&1) ]]; then
  gem install bundler
fi

# Nodejs
if [[ ! $(asdf plugin list | grep nodejs) ]]; then
  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  brew_install gpg
  brew_install coreutils
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
fi
if [[ ! $(asdf list nodejs | grep "$NODE_VERSION") ]]; then
  asdf install nodejs "$NODE_VERSION"
  asdf global nodejs "$NODE_VERSION"
fi

# Uninstall default java8
if [[ -d "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin" ]]; then
  sudo rm -fr "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"
fi
if [[ -d "/Library/PreferencesPanes/JavaControlPanel.prefPane" ]]; then
  sudo rm -fr "/Library/PreferencesPanes/JavaControlPanel.prefPane"
fi
if [[ -d "$HOME/Library/Application Support/Java" ]]; then
  sudo rm -fr "$HOME/Library/Application Support/Java"
fi

# Java
if [[ ! $(asdf plugin list | grep java) ]]; then
  asdf plugin-add java https://github.com/halcyon/asdf-java.git
fi
if [[ ! $(asdf list java | grep "$JAVA_VERSION") ]]; then
  asdf install java "$JAVA_VERSION"
  asdf global java "$JAVA_VERSION"
fi

# kotlin
if [[ ! $(asdf plugin list | grep kotlin) ]]; then
  asdf plugin-add kotlin https://github.com/asdf-community/asdf-kotlin.git
fi
if [[ ! $(asdf list java | grep "$KOTLIN_VERSION") ]]; then
  asdf install kotlin "$KOTLIN_VERSION"
  asdf global kotlin "$KOTLIN_VERSION"
fi

# Android
brew_cask_install android-studio
brew_install apktool
brew_install bundletool

# Graph
brew_install graphviz
brew_install plantuml

# Other applications
brew_install bitwarden-cli

brew_cask_install karabiner-elements
brew_cask_install aquaskk
brew_cask_install iterm2
brew_cask_install visual-studio-code
brew_cask_install istat-menus
brew_cask_install the-unarchiver
brew_cask_install microsoft-office
brew_cask_install firefox

if [[ ! -d "/Applications/zoom.us.app" ]]; then
  brew_cask_install zoom
fi
if [[ ! -d "/Applications/Google Chrome.app" ]]; then
  brew_cask_install google-chrome
fi
if [[ ! -d "/Applications/Slack.app" ]]; then
  brew_cask_install slack
fi

mas_install 539883307 # LINE

# Fonts
install_ricty
