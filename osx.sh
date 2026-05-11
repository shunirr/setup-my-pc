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

brew_install neovim

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

# Modern CLI tools
brew_install fzf
brew_install ripgrep
brew_install fd
brew_install bat
brew_install eza
brew_install zoxide
brew_install git-delta
brew_install direnv
brew_install ghq

# mise
uninstall_asdf
brew_install mise
mise trust -a
mise_install_all
uninstall_java8

# Python
install_uv

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

# AI
brew_cask_install claude
brew_cask_install lm-studio
brew_cask_install codex
brew_install claude-code
brew install gemini-cli

brew_cask_install cmux

brew_cask_install karabiner-elements
brew_cask_install wezterm
brew_cask_install visual-studio-code
brew_cask_install google-chrome
brew_cask_install proxyman
brew_cask_install rancher
brew_cask_install betterdisplay
brew_cask_install obsidian
brew_cask_install istat-menus

brew_cask_install macskk

if [ "$IS_PERSONAL" = 'true' ]; then
  brew_cask_install adobe-creative-cloud
  brew_cask_install synology-drive
  mas_install 302584613 kindle
  mas_install 1475387142 tail-scale

  # 3D CAD
  brew_cask_install bambu-studio
  brew_cask_install autodesk-fusion
fi

# Mac App Store
brew_install mas
mas_install 539883307 line
mas_install 803453959 slack
mas_install 425424353 the-unarchiver
mas_install 1352778147 bitwarden
mas_install 640199958 # Developer

info "Upgrade all casks (excluding auto-update apps)"
EXCLUDE_CASKS="autodesk-fusion"
OUTDATED_CASKS=$(brew outdated --cask --quiet | grep -v -E "^(${EXCLUDE_CASKS})$" || true)
if [ -n "$OUTDATED_CASKS" ]; then
  echo "$OUTDATED_CASKS" | xargs brew upgrade --cask
fi

info "Upgrade all apps that managed MacAppStore"
mas upgrade

# macOS settings
configure_macos_defaults

info "Cleanup"
brew autoremove
brew cleanup --prune=all
