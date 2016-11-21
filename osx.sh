#!/bin/bash

# Constants {{{1
RUBY_VERSION="2.3.3"

# Functions {{{1
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
  brew install caskroom/cask/brew-cask
}
# Main Process {{{1
add_sudoers
join_wheel_group

[[ ! -d ~/.ssh ]] && ssh_keygen

install_command_line_developer_tools

homebrew_init

# Applications {{{2
brew cask install \
  karabiner \
  seil \
  dropbox

# Tools {{{2
brew install \
  tmux \
  wget \
  gnu-sed \
  the_silver_searcher \
  jq

# Bash {{{2
brew install \
  bash \
  bash-completion

echo /usr/local/bin/bash | sudo tee -a /etc/shells
chsh -s /usr/local/bin/bash

# Ruby {{{2
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

ruby -v

# Android {{{2
brew cask install \
  java

brew install \
  apktool

# Vim {{{2
mkdir -p ~/.vim/bundle
pushd ~/.vim/bundle
  curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
  sh installer.sh .
popd
