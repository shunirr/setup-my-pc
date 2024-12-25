#!/usr/bin/env bash
set -euxo pipefail

RUBY_VERSION="3.3.6"
PYTHON_VERSION="3.13.1"
NODE_VERSION="22.12.0"
JAVA_VERSION="adoptopenjdk-11.0.25+9"
KOTLIN_VERSION="2.1.0"
GOLANG_VERSION="1.23.4"
DENO_VERSION="2.1.4"

wait_process() {
  sleep 5
  while true; do
    sleep 1
    if ! pgrep "$1"; then
      break
    fi
  done
}

ssh_keygen() {
  SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
  if [ $# -eq 1 ]; then
    SSH_KEY_PATH="${SSH_KEY_PATH}_$1"
  fi
  if [ ! -f "$SSH_KEY_PATH" ]; then
    ssh-keygen -f "$SSH_KEY_PATH" -N "" -t ed25519
  fi
}

add_sudoers() {
  if [ ! -d "/etc/sudoers.d" ] || [ ! -f "/etc/sudoers.d/config" ]; then
    sudo mkdir -p /etc/sudoers.d
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/config
    sudo chmod 440 /etc/sudoers.d/*
  fi
}

join_wheel_group() {
  USERNAME="$(who am i | cut -d" " -f1)"
  if ! dscl . -read /Groups/wheel | grep -q "$USERNAME"; then
    sudo dscl . -append /Groups/wheel GroupMembership "$USERNAME"
  fi
}

install_command_line_developer_tools() {
  if [ ! -d "/Library/Developer/CommandLineTools" ]; then
    /bin/bash -c "xcode-select --install" &
    wait_process "Command Line Developer Tools"
  fi
}

install_homebrew() {
  if ! type brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    if [ "$(uname)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi
}

homebrew_init() {
  install_homebrew
  brew update
  brew upgrade
}

brew_install() {
  if [ ! -d "$(brew --prefix)/Cellar/$1" ]; then
    brew install "$1"
  fi
}

brew_cask_install() {
  if [ ! -d "$1" ] && [ ! -d "$(brew --prefix)/Caskroom/$2" ]; then
    set +e
    brew install --cask "$2"
    set -e
  fi
}

mas_install() {
  if ! mas list | grep -q "$1"; then
    mas install "$1"
  fi
}

install_hackgen() {
  if [ -z "$(find "$HOME/Library/Fonts" -name 'HackGen*.ttf')" ]; then
    brew tap homebrew/cask-fonts
    brew_install font-hackgen
    brew_install font-hackgen-nerd
  fi
}

install_rosetta2() {
  if [ "$(uname)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ]; then
    softwareupdate --install-rosetta --agree-to-license
  fi
}

uninstall_asdf() {
  if [ -d "$(brew --prefix)/Cellar/asdf" ]; then
    brew uninstall --force asdf
    brew autoremove
  fi
  if [ -f "$HOME/.asdfrc" ]; then
    rm -rf "$HOME/.asdfrc"
  fi
  if [ -d "$HOME/.tool-versions" ]; then
    rm -rf "$HOME/.tool-versions"
  fi
  if [ -d "$HOME/.asdf" ]; then
    rm -rf "$HOME/.asdf"
  fi
}

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
if ! shellcheck "$0"; then
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
brew_install mise

# Ruby
brew_install libyaml
mise use --global "ruby@$RUBY_VERSION"

if ! which bundle | grep -q "mise"; then
  gem install bundler
fi

# Python
mise use --global "python@$PYTHON_VERSION"

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
brew_cask_install "/Applications/iStat Menus.app" istat-menus
brew_cask_install "/Applications/Microsoft Word.app" microsoft-office
brew_cask_install "/Applications/zoom.us.app" zoom
brew_cask_install "/Applications/Google Chrome.app" google-chrome
brew_cask_install "/Applications/Slack.app" slack
brew_cask_install "/Applications/The Unarchiver.app" the-unarchiver
brew_cask_install "/Applications/Proxyman.app" proxyman

if [ "$IS_PERSONAL" = 'true' ]; then
  brew_cask_install "/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app" adobe-creative-cloud
else
  ssh_keygen "w"
  brew_cask_install "/Applications/Firefox.app" firefox
  brew_cask_install "/Applications/Dialpad.app" dialpad
fi

mas_install 539883307 # LINE

# Fonts
install_hackgen

# Upgrade all casks
brew upgrade --cask --greedy -f

# Upgarde all apps that managed MacAppStore
mas upgrade

# Upgrade macOs
# softwareupdate --all --install --force

brew_install shfmt
shfmt -l -w -i 2 "$0"
