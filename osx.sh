#!/bin/bash

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
  if [ ! -f "/var/db/receipts/com.apple.pkg.DeveloperToolsCLI.bom" ]; then
    sh -c "xcode-select --install"
    wait_process "Command Line Developer Tools"
    sudo xcodebuild -license accept
  fi
}

install_homebrew() {
  which brew >/dev/null 2>&1
  if [ $? != 0 ]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

brew_tap() {
  local TAP_NAME=$(echo "$1" | sed "s/homebrew-//")
  if [ ! $(brew tap | grep $TAP_NAME) ]; then
    brew tap $1
  fi
}

homebrew_init() {
  install_homebrew
  brew update
  brew tap homebrew/cask-cask
}

########

add_sudoers
join_wheel_group

[[ ! -d ~/.ssh ]] && ssh_keygen

install_command_line_developer_tools

homebrew_init

brew install mas
mas install 497799835 # Xcode (10.1)

brew cask install karabiner-elements

# IME
brew cask install aquaskk

brew install \
  tmux \
  wget \
  the_silver_searcher \
  jq

# bash
brew install \
  bash \
  bash-completion

echo /usr/local/bin/bash | sudo tee -a /etc/shells
chsh -s /usr/local/bin/bash

# Ruby
RUBY_VERSION="2.5.3"

brew install \
  rbenv \
  ruby-build \
  rbenv-gemset \
  rbenv-gem-rehash

if [ ! -f /usr/local/etc/openssl/cert.pem ]; then
  brew install curl-ca-bundle
  cp "$(brew list curl-ca-bundle)" /usr/local/etc/openssl/cert.pem
fi

rbenv install ${RUBY_VERSION}
rbenv global ${RUBY_VERSION}
gem install bundler

# Android
brew cask install java
brew cask install android-studio
brew install apktool

# Other applications

brew cask install visual-studio-code

mas install 425424353 # The Unarchiver (4.0.0)
mas install 918858936 # Airmail 3 (3.6.50)
mas install 412485838 # Witch (3.9.8)
mas install 803453959 # Slack (3.3.3)
mas install 407963104 # Pixelmator (3.7.5)
mas install 539883307 # LINE (5.11.2)
mas install 1024640650 # CotEditor (3.6.6)
