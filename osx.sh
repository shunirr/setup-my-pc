#!/bin/bash -x

set -eu

wait_process() {
  sleep 5
  while true; do
    sleep 1
    pgrep "$1" >/dev/null 2>&1
    if [ $? != 0 ]; then
      break
    fi
  done
}

ssh_keygen() {
  expect -c "
  spawn ssh-keygen
  expect :\ ; send \n
  expect :\ ; send \n
  expect :\ ; send \n
  expect eof exit 0
  "
}

add_sudoers() {
  local ENTRY='%wheel ALL=(ALL) NOPASSWD: ALL'
  if [ ! "$(sudo cat /etc/sudoers | grep '${ENTRY}')" ]; then
    sudo sh -c "echo '${ENTRY}' >> /etc/sudoers"
  fi
}

join_wheel_group() {
  local USERNAME=$(who am i | cut -d" " -f1)
  if [ ! "$(dscl . -read /Groups/wheel | grep ${USERNAME})" ]; then
    sudo dscl . -append /Groups/wheel GroupMembership ${USERNAME}
  fi
}

install_command_line_developer_tools() {
  if [ ! -f "/var/db/receipts/com.apple.pkg.Xcode.bom" ]; then
    sh -c "xcode-select --install"
    wait_process "Command Line Developer Tools"
    sudo xcodebuild -license accept
  fi
}

install_homebrew() {
  which brew >/dev/null 2>&1
  if [ $? != 0 ]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

homebrew_init() {
  install_homebrew
  brew update
}

########

add_sudoers
join_wheel_group

[[ ! -d ~/.ssh ]] && ssh_keygen

install_command_line_developer_tools

homebrew_init

brew install mas

mas install 497799835 # Xcode (10.1)
sudo xcodebuild -license accept

brew cask install karabiner-elements

brew cask install aquaskk

brew install \
  tmux \
  wget \
  the_silver_searcher \
  jq

# bash
brew install \
  bash \
  bash-completion

if [ ! $(cat /etc/shells | grep /usr/local/bin/bash) ]; then
  echo /usr/local/bin/bash | sudo tee -a /etc/shells
fi
chsh -s /usr/local/bin/bash

# asdf
brew install asdf
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.bash_profile
echo -e "\n. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" >> ~/.bash_profile

# ruby
if [ ! $(asdf plugin list | grep ruby) ]; then
  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
  asdf install ruby 2.7.0
  asdf global ruby 2.7.0
  gem install bundler
fi

# nodejs
if [ ! $(asdf plugin list | grep nodejs) ]; then
  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  brew install gpg coreutils
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
  asdf install nodejs 14.15.1
  asdf global nodejs 14.15.1
fi

# java
brew install openjdk

# Android
brew cask install android-studio
brew install apktool bundletool

# Other applications

brew cask install iterm2
brew cask install visual-studio-code
brew cask install notable

mas install 425424353 # The Unarchiver (4.0.0)
mas install 918858936 # Airmail 3 (3.6.50)
mas install 412485838 # Witch (3.9.8)
mas install 803453959 # Slack (3.3.3)
mas install 539883307 # LINE (5.11.2)
mas install 1024640650 # CotEditor (3.6.6)
