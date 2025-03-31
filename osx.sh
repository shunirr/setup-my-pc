#!/usr/bin/env bash
set -euxo pipefail

source ./lib/utils.sh

RUBY_VERSION="3.3.6"
PYTHON_VERSION="3.13.1"
PYTHON_POETRY_VERSION="1.8.5"
NODE_VERSION="22.12.0"
JAVA_VERSION="adoptopenjdk-11.0.25+9"
KOTLIN_VERSION="2.1.0"
GOLANG_VERSION="1.23.4"
DENO_VERSION="2.1.4"

########

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

homebrew_init

brew_install mas

# mas_install 497799835 # Xcode
# sudo xcodebuild -license accept

brew_install shellcheck
if ! shellcheck "$0" "./lib/utils.sh"; then
  echo "Please fix shellcheck's problems"
  exit 1
fi

brew_install git
brew_install git-lfs
brew_install tmux
brew_install wget
brew_install the_silver_searcher
brew_install jq
brew_install ccache
brew_install cmake
brew_install pkg-config

# Copy dot-files
cp -v -R dot-files/. "$HOME"

# Bash
brew_install bash
brew_install bash-completion

if ! grep <"/etc/shells" -q "$(which bash)"; then
  which bash | sudo tee -a /etc/shells
fi
if [ "$(dscl localhost -read "Local/Default/Users/$USER" UserShell | cut -d' ' -f2)" != "$(which bash)" ]; then
  chsh -s "$(which bash)"
fi

if [ ! -f "$HOME/.bashrc_private" ]; then
  touch "$HOME/.bashrc_private"
fi

# Load bashrc
# shellcheck disable=SC1091
source "$HOME/.bashrc"

# uninstall asdf
uninstall_asdf

# mise
curl https://mise.run | sh

# Ruby
brew_install libyaml
mise use --global "ruby@$RUBY_VERSION"

if ! which bundle | grep -q "mise"; then
  gem install bundler
fi

# Python
mise use --global "python@$PYTHON_VERSION"
mise plugin add poetry
mise use --global "poetry@$PYTHON_POETRY_VERSION"

# Nodejs
mise use --global "nodejs@$NODE_VERSION"
if ! which yarn | grep -q "mise"; then
  npm install -g yarn
fi
if ! which pnpm | grep -q "mise"; then
  npm install -g pnpm
fi

# Deno
mise use --global "deno@$DENO_VERSION"

# Uninstall default java8
if [ -d "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin" ]; then
  sudo rm -rf "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"
fi
if [ -d "/Library/PreferencesPanes/JavaControlPanel.prefPane" ]; then
  sudo rm -rf "/Library/PreferencesPanes/JavaControlPanel.prefPane"
fi
if [ -d "$HOME/Library/Application Support/Java" ]; then
  sudo rm -rf "$HOME/Library/Application Support/Java"
fi

# Java
mise use --global "java@$JAVA_VERSION"

# Kotlin
mise use --global "kotlin@$KOTLIN_VERSION"

# Golang
mise use --global "golang@$GOLANG_VERSION"

# reshim
mise reshim --force

# Flutter
if [ ! -f "$HOME/.fenv/bin/fenv" ]; then
  curl -fsSL "https://fenv-install.jerry.company" | bash
  # shellcheck disable=SC2086
  $HOME/.fenv/bin/fenv init
fi

# Android
brew_cask_install "/Applications/Android Studio.app" android-studio
brew_install apktool
brew_install bundletool

# Java
brew_cask_install "/Applications/IntelliJ IDEA CE.app" intellij-idea-ce

# Graph
brew_install graphviz
brew_install plantuml

# Terraform
brew_install awscli
brew_install tfenv

# Xcodes
brew_install xcodesorg/made/xcodes
brew_cask_install "/Applications/Xcodes.app" xcodes

# Other applications
brew_install bitwarden-cli

brew_cask_install "/Applications/Karabiner-Elements.app" karabiner-elements
brew_cask_install "/Library/Input Methods/AquaSKK.app" aquaskk
brew_cask_install "/Applications/WezTerm.app" wezterm
brew_cask_install "/Applications/Visual Studio Code.app" visual-studio-code
brew_cask_install "/Applications/Microsoft Word.app" microsoft-office
brew_cask_install "/Applications/zoom.us.app" zoom
brew_cask_install "/Applications/Google Chrome.app" google-chrome
brew_cask_install "/Applications/Proxyman.app" proxyman
brew_cask_install "/Applications/Finicky.app" finicky
brew_cask_install "/Applications/Rancher Desktop.app" rancher
brew_cask_install "/Applications/BetterDisplay.app" betterdisplay
brew_cask_install "/Applications/Obsidian.app" obsidian

if [ "$IS_PERSONAL" = 'true' ]; then
  brew_cask_install "/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app" adobe-creative-cloud
  brew_cask_install "/Applications/Claude.app" claude
  brew_cask_install "/Applications/Cursor.app" cursor
else
  ssh_keygen "w"
  brew_cask_install "/Applications/Firefox.app" firefox
  brew_cask_install "/Applications/Dialpad.app" dialpad
  brew_cask_install "/Applications/Box.app" box-drive
fi

mas_install line 539883307
mas_install slack 803453959
mas_install the-unarchiver 425424353

# Fonts
install_hackgen

# Upgrade all casks
brew upgrade --cask --greedy -f

# Upgrade all apps that managed MacAppStore
mas upgrade

# Upgrade macOs
# softwareupdate --all --install --force
