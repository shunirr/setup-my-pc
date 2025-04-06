#!/usr/bin/env bash

info() {
  echo -e "\e[35m[INFO]\e[m $1"
}

wait_process() {
  info "Waiting Process: $1"
  set +e
  sleep 5
  while true; do
    sleep 1
    if ! pgrep "$1"; then
      break
    fi
  done
  set -e
}

ssh_keygen() {
  info "Generating SSH key"
  SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
  if [ -n "$1" ]; then
    SSH_KEY_PATH="${SSH_KEY_PATH}_$1"
  fi
  if [ ! -f "$SSH_KEY_PATH" ]; then
    ssh-keygen -f "$SSH_KEY_PATH" -N "" -t ed25519
  fi
}

add_sudoers() {
  info "Adding sudoers"
  if [ ! -d "/etc/sudoers.d" ] || [ ! -f "/etc/sudoers.d/config" ]; then
    sudo mkdir -p "/etc/sudoers.d"
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' | sudo tee "/etc/sudoers.d/config"
    sudo chmod 440 "/etc/sudoers.d/*"
  fi
}

join_wheel_group() {
  info "Joining wheel group"
  if ! dscl . -read "/Groups/wheel" | grep -q "$USER"; then
    sudo dscl . -append "/Groups/wheel" "GroupMembership" "$USER"
  fi
}

install_command_line_developer_tools() {
  info "Installing Command Line Developer Tools"
  if [ ! -d "/Library/Developer/CommandLineTools" ]; then
    /bin/bash -c "xcode-select --install" &
    wait_process "Command Line Developer Tools"
  fi
}

install_homebrew() {
  info "Installing Homebrew"
  if ! type brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh')"
    if [ "$(uname)" = "Darwin" ]; then
      if [ "$(uname -m)" = "arm64" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      else
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    fi
  fi
}

homebrew_init() {
  install_homebrew
  brew update
  brew upgrade
}

BREW_INSTALLED=""
brew_install() {
  info "Installing Homebrew: $1"
  if [ -z "$BREW_INSTALLED" ]; then
    BREW_INSTALLED="$(brew info --installed --json | jq '.[].full_name')"
  fi
  if ! echo "$BREW_INSTALLED" | grep -q \""$1"\"; then
    brew install "$1"
  fi
}

brew_cask_install() {
  info "Installing Cask: $1"
  if [ ! -d "$(brew --prefix)/Caskroom/$1" ]; then
    brew install --cask -f "$1"
  fi
}

mas_install() {
  info "Installing MacAppStore: $1"
  if ! mas list | grep -q "$1"; then
    mas install "$2"
  fi
  if [ $# -eq 2 ] && [ -d "$(brew --prefix)/Caskroom/$2" ]; then
    brew uninstall "$2"
  fi
}

RUBY_GEMS_INSTALLED=""
gem_install() {
  info "Installing RubyGems: $1"
  if [ -z "$RUBY_GEMS_INSTALLED" ]; then
    RUBY_GEMS_INSTALLED="$(gem list --local | awk '{print $1}')"
  fi
  if ! echo "$RUBY_GEMS_INSTALLED" | grep -q "$1"; then
    gem install "$1"
  fi
}

npm_install() {
  info "Installing NPM: $1"
  if ! type "$1" >/dev/null 2>&1; then
    npm install -g "$1"
  fi
}

install_hackgen() {
  info "Installing HackGen"
  if [ -z "$(find "$HOME/Library/Fonts" -name 'HackGen*.ttf')" ]; then
    brew_install font-hackgen
    brew_install font-hackgen-nerd
  fi
}

install_rosetta2() {
  info "Installing Rosetta 2"
  if [ "$(uname -m)" = "arm64" ]; then
    softwareupdate --install-rosetta --agree-to-license
  fi
}

uninstall_asdf() {
  info "Uninstalling asdf"
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

uninstall_java8() {
  info "Uninstalling Java 8"
  if [ -d "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin" ]; then
    sudo rm -rf "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"
  fi
  if [ -d "/Library/PreferencesPanes/JavaControlPanel.prefPane" ]; then
    sudo rm -rf "/Library/PreferencesPanes/JavaControlPanel.prefPane"
  fi
  if [ -d "$HOME/Library/Application Support/Java" ]; then
    sudo rm -rf "$HOME/Library/Application Support/Java"
  fi
}

install_fenv() {
  info "Installing fenv"
  if [ ! -f "$HOME/.fenv/bin/fenv" ]; then
    curl -fsSL "https://fenv-install.jerry.company" | bash
    "$HOME/.fenv/bin/fenv" init
  fi
}

change_shell() {
  info "Changing Shell: $1"
  if ! grep <"/etc/shells" -q "$1"; then
    echo "$1" | sudo tee -a "/etc/shells"
  fi
  if [ "$(dscl localhost -read "Local/Default/Users/$USER" UserShell | cut -d' ' -f2)" != "$1" ]; then
    chsh -s "$1"
  fi
}

install_mise() {
  info "Installing mise"
  if ! type mise >/dev/null 2>&1; then
    curl "https://mise.run" | sh
  fi
  mise trust -a
}

mise_plugin_add() {
  info "Adding mise plugin: $1"
  if ! mise plugin list | grep -q "$1"; then
    mise plugin add "$1"
  fi
}

mise_install_all() {
  info "Installing all apps by mise"
  mise install
}

copy_dotfiles() {
  info "Copy dotfiles"
  cp -R "dot-files/." "$HOME"
}

use_bash() {
  info "Using bash from Homebrew"
  brew_install bash
  brew_install bash-completion
  change_shell "$(brew --prefix)/bin/bash"
  if [ ! -f "$HOME/.bashrc_private" ]; then
    touch "$HOME/.bashrc_private"
  fi
  # shellcheck source=/dev/null
  source "$HOME/.bashrc"
}

install_xcodes() {
  info "Installing xcodes"
  brew_install xcodesorg/made/xcodes
  brew_cask_install xcodes
  if ! type xcodes >/dev/null 2>&1; then
    brew link xcodes
  fi
}

install_xcode_by_xcodes() {
  install_xcodes

  info "Install Xcode by xcodes"
  xcodes install
  xcodes select
  sudo xcodebuild -license accept
}

VSCODE_EXTENSIONS=""
install_vscode_extension() {
  info "Installing VSCode Extension: $1"
  if [ -z "$VSCODE_EXTENSIONS" ]; then
    VSCODE_EXTENSIONS="$(code --list-extensions)"
  fi
  if ! echo "$VSCODE_EXTENSIONS" | grep -q "$1"; then
    code --install-extension "$1"
  fi
}
