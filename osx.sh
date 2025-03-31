#!/usr/bin/env bash
set -euo pipefail

source ./lib/utils.sh

if [ $# -eq 1 ] && [ "$1" = "p" ]; then
  IS_PERSONAL="true"
elif [ $# -eq 1 ] && [ "$1" = "w" ]; then
  IS_PERSONAL="false"
else
  echo "Invalid argument: Please set p or w"
  exit 1
fi

add_sudoers
join_wheel_group
ssh_keygen

install_rosetta2
install_command_line_developer_tools

copy_dotfiles

homebrew_init

install_hackgen

brew_install "git"
brew_install "git-lfs"
brew_install "wget"
brew_install "jq"
brew_install "ccache"
brew_install "cmake"
brew_install "pkgconf"

# Bash
brew_install "bash"
brew_install "bash-completion"
change_shell "$(which bash)"
if [ ! -f "$HOME/.bashrc_private" ]; then
  touch "$HOME/.bashrc_private"
fi
source "./dot-files/.bashrc"

uninstall_asdf
uninstall_java8

# mise
install_mise

# Ruby
brew_install "libyaml"
gem_install "bundler"

# Python
mise_plugin_add "poetry"

# Nodejs
npm_install "yarn"
npm_install "pnpm"

mise_install_all

# Flutter
install_fenv

# Android
brew_cask_install "android-studio"
brew_install "apktool"
brew_install "bundletool"

# Graph
brew_install "graphviz"
brew_install "plantuml"

# Terraform
brew_install "awscli"
brew_install "tfenv"

# Xcodes
brew_install "xcodesorg/made/xcodes"
brew_cask_install "xcodes"

info "Install Xcode by xcodes"
xcodes install --latest
sudo xcodebuild -license accept

brew_install "bitwarden-cli"

brew_cask_install "karabiner-elements"
brew_cask_install "aquaskk"
brew_cask_install "wezterm"
brew_cask_install "visual-studio-code"
brew_cask_install "microsoft-office"
brew_cask_install "zoom"
brew_cask_install "google-chrome"
brew_cask_install "proxyman"
brew_cask_install "finicky"
brew_cask_install "rancher"
brew_cask_install "betterdisplay"
brew_cask_install "obsidian"

if [ "$IS_PERSONAL" = 'true' ]; then
  brew_cask_install "adobe-creative-cloud"
  brew_cask_install "claude"
  brew_cask_install "cursor"
else
  ssh_keygen "w"
  brew_cask_install "firefox"
  brew_cask_install "dialpad"
  brew_cask_install "box-drive"
fi

# Mac App Store
brew_install "mas"
mas_install "line"           "539883307"
mas_install "slack"          "803453959"
mas_install "the-unarchiver" "425424353"

info "Upgrade all casks"
brew upgrade --cask --greedy -f

info "Upgrade all apps that managed MacAppStore"
mas upgrade