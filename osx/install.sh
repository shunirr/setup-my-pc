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

brew cask install iterm2
brew cask install limechat
brew cask install google-chrome
brew cask install intellij-idea
brew cask install gyazo
brew cask install dropbox
brew cask install istat-menus
brew cask install keyremap4macbook
brew cask install pckeyboardhack
brew cask install skype
brew cask install sourcetree
brew cask install the-unarchiver
brew cask install vlc
brew cask install witch
brew cask install xtrafinder

# Tools
brew install zsh
brew install tmux
brew install tree
brew install wget
brew install gnu-sed
brew install the_silver_searcher
brew install jq
brew install nkf
brew install watch
brew install fswatch
brew install boot2docker

# Ruby
brew install curl-ca-bundle
brew install rbenv
brew install ruby-build
brew install rbenv-gemset
brew install rbenv-gem-rehash
brew install readline
brew install apple-gcc42

# Android
brew cask install java
brew install android-sdk
brew install android-ndk
brew install apktool

# Android SDK
yes 'y' | android update sdk --no-ui --force

brew cask install virtualbox
brew cask install vagrant
brew cask install mono-mdk

brew cask install lastpass-universal

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

