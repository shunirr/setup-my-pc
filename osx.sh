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


# VSCode Extensions
install_vscode_extension "ms-ceintl.vscode-language-pack-ja"

# Markdown
install_vscode_extension "bierner.markdown-mermaid"
install_vscode_extension "bpruitt-goddard.mermaid-markdown-syntax-highlighting"
install_vscode_extension "yzhang.markdown-all-in-one"

install_vscode_extension "charliermarsh.ruff"
install_vscode_extension "chiehyu.vscode-astyle"
install_vscode_extension "streetsidesoftware.code-spell-checker"

# Flutter
install_vscode_extension "dart-code.dart-code"
install_vscode_extension "dart-code.flutter"

# JavaScript
install_vscode_extension "dbaeumer.vscode-eslint"
install_vscode_extension "esbenp.prettier-vscode"
install_vscode_extension "orta.vscode-jest"
install_vscode_extension "svelte.svelte-vscode"

# Deno
install_vscode_extension "denoland.vscode-deno"

# Git
install_vscode_extension "eamodio.gitlens"
install_vscode_extension "mhutchie.git-graph"

install_vscode_extension "github.copilot"
install_vscode_extension "github.copilot-chat"
install_vscode_extension "github.vscode-github-actions"

# Shell Script
install_vscode_extension "foxundermoon.shell-format"
install_vscode_extension "timonwong.shellcheck"

# Golang
install_vscode_extension "golang.go"

# Graph
install_vscode_extension "jebbs.plantuml"
install_vscode_extension "tintinweb.graphviz-interactive-preview"

# Android
install_vscode_extension "mathiasfrohlich.kotlin"
install_vscode_extension "vscjava.vscode-gradle"

# Python
install_vscode_extension "ms-python.black-formatter"
install_vscode_extension "ms-python.debugpy"
install_vscode_extension "ms-python.python"
install_vscode_extension "ms-python.vscode-pylance"

install_vscode_extension "hashicorp.terraform"

install_vscode_extension "mechatroner.rainbow-csv"
install_vscode_extension "ms-azuretools.vscode-docker"
install_vscode_extension "ms-vscode-remote.remote-containers"
install_vscode_extension "redhat.vscode-xml"
install_vscode_extension "vscodevim.vim"
install_vscode_extension "editorconfig.editorconfig"

info "Upgrade all casks"
brew upgrade --cask --greedy -f

info "Upgrade all apps that managed MacAppStore"
mas upgrade

info "Cleanup"
brew autoremove
brew cleanup --prune=all
