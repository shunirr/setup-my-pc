#!/usr/bin/env bash
set -euxo pipefail

RUBY_VERSION="3.2.1"
NODE_VERSION="18.15.0"
JAVA_VERSION="adoptopenjdk-11.0.18+10"
KOTLIN_VERSION="1.8.10"
GOLANG_VERSION="1.20.2"
DENO_VERSION="1.38.1"

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

mas_install 497799835 # Xcode
sudo xcodebuild -license accept

brew_install shellcheck
if ! shellcheck "$0"; then
  echo "Please fix shellcheck's problems"
  exit 1
fi

brew_install git
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

# asdf
brew_install asdf
asdf plugin update --all

# Ruby
if ! asdf plugin list | grep -q ruby; then
  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
fi
if ! asdf list ruby | grep -q "$RUBY_VERSION"; then
  if [ "$(uname)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ]; then
    export RUBY_CFLAGS=-DUSE_FFI_CLOSURE_ALLOC
  fi
  asdf install ruby "$RUBY_VERSION"
fi
asdf global ruby "$RUBY_VERSION"

if ! which bundle | grep -q "asdf"; then
  gem install bundler
fi

# Nodejs
if ! asdf plugin list | grep -q nodejs; then
  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  brew_install gpg
  brew_install coreutils
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
fi
if ! asdf list nodejs | grep -q "$NODE_VERSION"; then
  asdf install nodejs "$NODE_VERSION"
fi
asdf global nodejs "$NODE_VERSION"
if ! which yarn | grep -q "asdf"; then
  npm install -g yarn
fi

# Deno
if ! asdf plugin list | grep -q deno; then
  asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git
fi
if ! asdf list deno | grep -q "$DENO_VERSION"; then
  asdf install deno "$DENO_VERSION"
fi
asdf global deno "$DENO_VERSION"

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
if ! asdf plugin list | grep -q java; then
  asdf plugin-add java https://github.com/halcyon/asdf-java.git
fi
if ! asdf list java | grep -q "$JAVA_VERSION"; then
  asdf install java "$JAVA_VERSION"
fi
asdf global java "$JAVA_VERSION"

# Kotlin
if ! asdf plugin list | grep -q kotlin; then
  asdf plugin-add kotlin https://github.com/asdf-community/asdf-kotlin.git
fi
if ! asdf list kotlin | grep -q "$KOTLIN_VERSION"; then
  asdf install kotlin "$KOTLIN_VERSION"
fi
asdf global kotlin "$KOTLIN_VERSION"

# Golang
if ! asdf plugin list | grep -q golang; then
  asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
fi
if ! asdf list golang | grep -q "$GOLANG_VERSION"; then
  asdf install golang "$GOLANG_VERSION"
fi
asdf global golang "$GOLANG_VERSION"

# reshim
if [ -d "$HOME/.asdf/shims" ]; then
  rm -rf "$HOME/.asdf/shims"
fi
asdf reshim

# Flutter
if [ ! -f "$HOME/.fenv/bin/fenv" ]; then
  curl -sSL "https://raw.githubusercontent.com/powdream/fenv/main/init.sh" | sh -
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
# brew_cask_install "/Applications/Docker.app" docker
brew_cask_install "/Applications/Slack.app" slack
brew_cask_install "/Applications/The Unarchiver.app" the-unarchiver

if [ "$IS_PERSONAL" = 'true' ]; then
  brew_cask_install "/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app" adobe-creative-cloud
  brew_cask_install "/Applications/Processing.app" processing
  brew_cask_install "/Applications/Eclipse Java.app" eclipse-java
  brew_cask_install "/Applications/Eclipse JEE.app" eclipse-jee
  brew_cask_install "/Applications/Raspberry Pi Imager.app" raspberry-pi-imager
  brew_cask_install "/Applications/Arduino IDE.app" arduino-ide
  brew_cask_install "/Applications/Google Drive.app" google-drive
else
  brew_cask_install "/Applications/Firefox.app" firefox
  ssh_keygen "w"
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
