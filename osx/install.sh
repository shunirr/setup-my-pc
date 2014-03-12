#!/bin/bash

wait_process() {
  sleep 5
  while : ; do
    [[ ! $(ps aux | grep "$1" | grep -v grep) ]] && break
    sleep 1
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
  if [ ! $(sudo cat /etc/sudoers | grep '${ENTRY}') ]; then
    sudo sh -c "echo '${ENTRY}' >> /etc/sudoers"
  fi
}

join_wheel_group() {
  local USERNAME=$(who am i | cut -d" " -f1)
  if [ ! $(dscl . -read /Groups/wheel | grep ${USERNAME}) ]; then
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
  if [ ! -f "/usr/local/Cellar" ]; then
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
  fi
}

homebrew_init() {
  install_homebrew
  brew update
  if [ ! $(brew tap | grep phinze/cask) ]; then
    brew tap phinze/homebrew-cask
  fi
  brew install brew-cask
}

add_sudoers
join_wheel_group

[[ ! -d ~/.ssh ]] && ssh_keygen

install_command_line_developer_tools

homebrew_init

# Applications
brew cask install \
  iterm2 \
  limechat \
  google-chrome \
  intellij-idea \
  gyazo \
  dropbox \
  istat-menus \
  keyremap4macbook \
  pckeyboardhack \
  skype \
  sourcetree \
  the-unarchiver \
  vlc \
  witch \
  xtrafinder \
  virtualbox \
  vagrant \
  mono-mdk \
  lastpass-universal

# Tools
brew install \
  zsh \
  tmux \
  tree \
  wget \
  gnu-sed \
  the_silver_searcher \
  jq \
  nkf \
  watch \
  fswatch \
  boot2docker

# Ruby
brew install \
  rbenv \
  ruby-build \
  rbenv-gemset \
  rbenv-gem-rehash \
  readline \
  apple-gcc42

# Android
brew cask install java
brew install \
  android-sdk \
  android-ndk \
  apktool

yes 'y' | android update sdk --no-ui --force

# dot-files
[[ ! -d ~/dev ]] && mkdir -p ~/dev
pushd ~/dev
  if [ ! -d dot-files ]; then
    git clone https://github.com:shunirr/dot-files.git
  fi
  pushd dot-files
    make
    make install
  popd
popd

if [ ! -f /usr/local/etc/openssl/cert.pem ]; then
  brew install curl-ca-bundle
  cp "$(brew list curl-ca-bundle)" /usr/local/etc/openssl/cert.pem
fi

rbenv install 2.1.0

