#!/usr/bin/env bash

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
  if [ -d "$(brew --prefix)/Caskroom/$1" ]; then
    brew uninstall "$1"
  fi
  if ! mas list | grep -q "$2"; then
    mas install "$2"
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