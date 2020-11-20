#!/bin/bash -x

set -eu

wait_process() {
  sleep 5
  while true; do
    sleep 1
    pgrep "$1" >/dev/null 2>&1
    if [ $? != 0 ]; then
      break
    fi
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
  if [ ! "$(sudo cat /etc/sudoers | grep '${ENTRY}')" ]; then
    sudo sh -c "echo '${ENTRY}' >> /etc/sudoers"
  fi
}

join_wheel_group() {
  local USERNAME=$(who am i | cut -d" " -f1)
  if [ ! "$(dscl . -read /Groups/wheel | grep ${USERNAME})" ]; then
    sudo dscl . -append /Groups/wheel GroupMembership ${USERNAME}
  fi
}

install_command_line_developer_tools() {
  if [ ! -f "/var/db/receipts/com.apple.pkg.Xcode.bom" ]; then
    sh -c "xcode-select --install"
    wait_process "Command Line Developer Tools"
    sudo xcodebuild -license accept
  fi
}

install_homebrew() {
  which brew >/dev/null 2>&1
  if [ $? != 0 ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
}

homebrew_init() {
  install_homebrew
  brew update
}

brew_install() {
  if [ ! -d /usr/local/Cellar/$1 ]; then
    brew install $1
  fi
}

brew_cask_install() {
  if [ ! -d /usr/local/Caskroom/$1 ]; then
    brew cask install $1
  fi
}

mas_install() {
  if [ ! "$(mas list | grep $1)" ]; then
    mas install $1
  fi
}

install_ricty() {
  if [ ! "$(ls ~/Library/Fonts/Ricty*.ttf)" ]; then
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

install_command_line_developer_tools

homebrew_init

brew_install mas

mas_install 497799835 # Xcode (10.1)
sudo xcodebuild -license accept

brew_install git
brew_install tmux
brew_install wget
brew_install the_silver_searcher
brew_install jq

# bash
brew_install bash
brew_install bash-completion

if [ ! "$(cat /etc/shells | grep /usr/local/bin/bash)" ]; then
  echo /usr/local/bin/bash | sudo tee -a /etc/shells
fi
if [ "$(dscl localhost -read Local/Default/Users/$USER UserShell | cut -d' ' -f2)" != "/usr/local/bin/bash" ]; then
  chsh -s /usr/local/bin/bash
fi

# asdf
brew_install asdf
if [ ! "$(asdf)" ]l then
  . $(brew --prefix asdf)/asdf.sh
fi

# ruby
if [ ! $(asdf plugin list | grep ruby) ]; then
  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
  asdf install ruby 2.7.0
  asdf global ruby 2.7.0
  gem install bundler
fi

# nodejs
if [ ! $(asdf plugin list | grep nodejs) ]; then
  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  brew_install gpg
  brew_install coreutils
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
  asdf install nodejs 14.15.1
  asdf global nodejs 14.15.1
fi

# java
brew_install openjdk

# Android
brew_cask_install android-studio
brew_install apktool bundletool

# Other applications
brew_cask_install karabiner-elements
brew_cask_install aquaskk

brew_cask_install iterm2
brew_cask_install visual-studio-code
brew_cask_install notable
brew_cask_install istat-menus

mas_install 425424353 # The Unarchiver
mas_install 803453959 # Slack
mas_install 539883307 # LINE
mas_install 1024640650 # CotEditor

# Fonts
install_ricty

# Copy dot-files
cp -v -R dot-files/. $HOME
