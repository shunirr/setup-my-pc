#!/bin/bash

wait_process() {
  while :
  do
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

sudo sh -c "echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
sudo dscl . -append /Groups/wheel GroupMembership $(who am i | cut -d" " -f1)

[[ ! -d ~/.ssh ]] && ssh_keygen
pushd ~/.ssh
  curl https://github.com/shunirr.keys -o authorized_keys
  chmod 600 authorized_keys
popd

# Command Line Developer Tools
xcode-select --install

wait_process "Command Line Developer Tools"

# Homebrew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

brew update
if [ ! $(brew tap | grep phinze/cask) ]; then
  brew tap phinze/homebrew-cask
fi
brew install brew-cask

brew cask install
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
  curl-ca-bundle \
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

# Android SDK
yes 'y' | android update sdk --no-ui --force

# dot-files
if [ ! -d ~/dev ]; then
  mkdir -p ~/dev
fi
pushd ~/dev
  if [ ! -d dot-files ]; then
    git clone https://github.com:shunirr/dot-files.git
  fi
  pushd dot-files
    make
    make install
  popd
popd

# Ruby
if [ ! -f /usr/local/etc/openssl/cert.pem ]; then
  cp "$(brew list curl-ca-bundle)" /usr/local/etc/openssl/cert.pem
fi

rbenv install 2.1.0

