#!/bin/sh

function reload_zsh_profile() {
  source ~/.zshenv
  source ~/.zshrc
}

# Command Line Developer Tools
xcode-select --install

# Homebrew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

brew bundle

# dot-files
mkdir -p ~/dev
cd ~/dev
git clone git@github.com:shunirr/dot-files.git
cd dot-files
make
make install
reload_zsh_profile()
cd

# Ruby
cp "$(brew list curl-ca-bundle)" /usr/local/etc/openssl/cert.pem
rbenv install 2.1.0
rbenv install 2.0.0-p353
rbenv install 1.9.3-p484

# Android SDK
yes 'y' | android update sdk --no-ui --force

