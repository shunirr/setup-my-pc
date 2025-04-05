#!/usr/bin/env bash
set -euo pipefail

source lib/utils.sh

IS_PERSONAL="false"
if [ $# -eq 1 ] && [ "$1" = "p" ]; then
  IS_PERSONAL="true"
fi

add_sudoers
join_wheel_group
ssh_keygen ""

install_rosetta2
install_command_line_developer_tools

copy_dotfiles

homebrew_init
brew_install git
brew_install git-lfs

install_hackgen

brew_install ccache
brew_install cmake
brew_install pkgconf
brew_install libyaml
brew_install gmp
brew_install ruby-build

# Bash
use_bash

# Shell
brew_install shellcheck
brew_install shfmt

# mise
uninstall_asdf
install_mise
mise_plugin_add poetry
mise_install_all
uninstall_java8

# Ruby
gem_install bundler

# NodeJS
npm_install yarn
npm_install pnpm

# Xcode
install_xcode_by_xcodes

# iOS
gem_install cocoapods

# Android
brew_cask_install android-studio
brew_install apktool
brew_install bundletool
brew_install dex2jar
brew_install jadx

# Flutter
install_fenv
fenv install

brew_install astyle
brew_install wget
brew_install jq
brew_install bitwarden-cli
brew_install tmux
brew_install gh
brew_install nkf
brew_install imagemagick
brew_install graphviz
brew_install plantuml
brew_install awscli
brew_install tfenv

brew_cask_install karabiner-elements
brew_cask_install aquaskk
brew_cask_install wezterm
brew_cask_install visual-studio-code
brew_cask_install microsoft-office
brew_cask_install zoom
brew_cask_install google-chrome
brew_cask_install proxyman
brew_cask_install rancher
brew_cask_install betterdisplay
brew_cask_install obsidian
brew_cask_install istat-menus

if [ "$IS_PERSONAL" = 'true' ]; then
  brew_cask_install adobe-creative-cloud
  brew_cask_install synology-drive
  mas_install 1037126344 # Apple Configurator
  mas_install 302584613 kindle
  mas_install 1475387142 tail-scale

  # AI
  brew_cask_install claude
  brew_cask_install cursor
  brew_cask_install lm-studio
fi

# Mac App Store
brew_install mas
mas_install 539883307 line 
mas_install 803453959 slack 
mas_install 425424353 the-unarchiver
mas_install 1352778147 bitwarden 
mas_install 640199958 # Developer 

info "Upgrade all casks"
brew upgrade --cask --greedy -f

info "Upgrade all apps that managed MacAppStore"
mas upgrade

info "Installing from Brewfile"
brew bundle install

info "Cleanup"
brew autoremove
brew cleanup
