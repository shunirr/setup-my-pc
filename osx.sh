#!/usr/bin/env bash -eux

RUBY_VERSION="2.6.9"
NODE_VERSION="16.8.0"
DENO_VERSION="1.28.3"
JAVA_VERSION="adoptopenjdk-11.0.16+101"
KOTLIN_VERSION="1.6.21"
GOLANG_VERSION="1.19.4"

wait_process() {
  sleep 5
  while true; do
    sleep 1
    set +e
    pgrep "$1" >/dev/null 2>&1
    if [[ $? != 0 ]]; then
      break
    fi
    set -e
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
  if [[ -z "$(sudo cat /etc/sudoers | grep "${ENTRY}")" ]]; then
    sudo sh -c "echo '${ENTRY}' >> /etc/sudoers"
  fi
}

join_wheel_group() {
  local USERNAME=$(who am i | cut -d" " -f1)
  if [[ -z "$(dscl . -read /Groups/wheel | grep ${USERNAME})" ]]; then
    sudo dscl . -append /Groups/wheel GroupMembership ${USERNAME}
  fi
}

install_command_line_developer_tools() {
  if [[ ! -d "/Library/Developer/CommandLineTools" ]]; then
    sh -c "xcode-select --install"
    wait_process "Command Line Developer Tools"
  fi
}

install_homebrew() {
  if [[ -z "$(brew --version)" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    if [[ $(uname) == "Darwin" ]] && [[ $(uname -m) == "arm64" ]]; then
      eval $(/opt/homebrew/bin/brew shellenv)
    fi
  fi
}

homebrew_init() {
  install_homebrew
  brew update
  brew upgrade
}

brew_install() {
  if [[ ! -d $(brew --prefix)/Cellar/$1 ]]; then
    brew install $1
  fi
}

brew_cask_install() {
  if [[ ! -d "$1" ]] && [[ ! -d $(brew --prefix)/Caskroom/$2 ]]; then
    set +e
    brew install --cask $2
    set -e
  fi
}

mas_install() {
  if [[ -z "$(mas list | grep $1)" ]]; then
    mas install $1
  fi
}

install_hackgen() {
  if [[ -z "$(ls ~/Library/Fonts/HackGen*.ttf)" ]]; then
    brew tap homebrew/cask-fonts
    brew_install font-hackgen
    brew_install font-hackgen-nerd
  fi
}

install_rosetta2() {
  if [[ "$(uname)" == "Darwin" ]] && [[ "$(uname -m)" == "arm64" ]]; then
    softwareupdate --install-rosetta --agree-to-license
  fi
}

########

add_sudoers
join_wheel_group

[[ ! -d ~/.ssh ]] && ssh_keygen

install_rosetta2

install_command_line_developer_tools

homebrew_init

brew_install mas

mas_install 497799835 # Xcode
sudo xcodebuild -license accept

brew_install git
brew_install tmux
brew_install wget
brew_install the_silver_searcher
brew_install jq
brew_install ccache
brew_install cmake
brew_install pkg-config

# Copy dot-files
cp -v -R dot-files/. $HOME

# Bash
brew_install bash
brew_install bash-completion

if [[ -z "$(cat /etc/shells | grep $(which bash))" ]]; then
  echo $(which bash) | sudo tee -a /etc/shells
fi
if [[ "$(dscl localhost -read Local/Default/Users/$USER UserShell | cut -d' ' -f2)" != "$(which bash)" ]]; then
  chsh -s $(which bash)
fi

[[ ! -f "$HOME/.bashrc_private" ]] && touch "$HOME/.bashrc_private"

# Load bashrc
source ~/.bashrc

# asdf
brew_install asdf
asdf plugin update --all

# Ruby
if [[ -z $(asdf plugin list | grep ruby) ]]; then
  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
fi
if [[ -z $(asdf list ruby | grep "$RUBY_VERSION") ]]; then
  if [[ "$(uname)" == "Darwin" ]] && [[ "$(uname -m)" == "arm64" ]]; then
    export RUBY_CFLAGS=-DUSE_FFI_CLOSURE_ALLOC
  fi
  asdf install ruby "$RUBY_VERSION"
  asdf global ruby "$RUBY_VERSION"
fi

softwareupdate --all --install --force
if [[ -z $(type bundle >/dev/null 2>&1 && echo "Installed") ]]; then
  gem install bundler
fi

# Nodejs
if [[ -z $(asdf plugin list | grep nodejs) ]]; then
  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  brew_install gpg
  brew_install coreutils
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
fi
if [[ -z $(asdf list nodejs | grep "$NODE_VERSION") ]]; then
  asdf install nodejs "$NODE_VERSION"
  asdf global nodejs "$NODE_VERSION"
fi
if [[ -z $(type yarn >/dev/null 2>&1 && echo "Installed") ]]; then
  npm install -g yarn
fi

# Deno
if [[ -z $(asdf plugin list | grep deno) ]]; then
  asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git
fi
if [[ -z $(asdf list deno | grep "$DENO_VERSION") ]]; then
  asdf install deno "$DENO_VERSION"
  asdf global deno "$DENO_VERSION"
fi

# Uninstall default java8
if [[ -d "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin" ]]; then
  sudo rm -fr "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"
fi
if [[ -d "/Library/PreferencesPanes/JavaControlPanel.prefPane" ]]; then
  sudo rm -fr "/Library/PreferencesPanes/JavaControlPanel.prefPane"
fi
if [[ -d "$HOME/Library/Application Support/Java" ]]; then
  sudo rm -fr "$HOME/Library/Application Support/Java"
fi

# Java
if [[ -z $(asdf plugin list | grep java) ]]; then
  asdf plugin-add java https://github.com/halcyon/asdf-java.git
fi
if [[ -z $(asdf list java | grep "$JAVA_VERSION") ]]; then
  asdf install java "$JAVA_VERSION"
  asdf global java "$JAVA_VERSION"
fi

# kotlin
if [[ -z $(asdf plugin list | grep kotlin) ]]; then
  asdf plugin-add kotlin https://github.com/asdf-community/asdf-kotlin.git
fi
if [[ -z $(asdf list kotlin | grep "$KOTLIN_VERSION") ]]; then
  asdf install kotlin "$KOTLIN_VERSION"
  asdf global kotlin "$KOTLIN_VERSION"
fi

# golang
if [[ -z $(asdf plugin list | grep golang) ]]; then
  asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
fi
if [[ -z $(asdf list golang | grep "$GOLANG_VERSION") ]]; then
  asdf install golang "$GOLANG_VERSION"
  asdf global golang "$GOLANG_VERSION"
fi

# reshim
if [[ -d "$HOME/.asdf/shims" ]]; then
  rm -rf "$HOME/.asdf/shims"
fi
asdf reshim

# Android
brew_cask_install "/Applications/Android Studio.app" android-studio
brew_install apktool
brew_install bundletool

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
brew_cask_install "/Applications/iTerm.app" iterm2
brew_cask_install "/Applications/Visual Studio Code.app" visual-studio-code
brew_cask_install "/Applications/iStat Menus.app" istat-menus
brew_cask_install "/Applications/Microsoft Word.app" microsoft-office
brew_cask_install "/Applications/Firefox.app" firefox
brew_cask_install "/Applications/Charles.app" charles
brew_cask_install "/Applications/zoom.us.app" zoom
brew_cask_install "/Applications/Google Chrome.app" google-chrome
brew_cask_install "/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app" adobe-creative-cloud
brew_cask_install "/Applications/Google Drive.app" google-drive
brew_cask_install "/Applications/Flipper.app" flipper
brew_cask_install "/Applications/Processing.app" processing
brew_cask_install "/Applications/Eclipse Java.app" eclipse-java
brew_cask_install "/Applications/Docker.app" docker

mas_install 539883307 # LINE
mas_install 803453959 # Slack
mas_install 425424353 # The Unarchiver

# Fonts
install_hackgen

# Upgrade all casks
brew upgrade --cask --greedy -f

# Upgarde all apps that managed MacAppStore
mas upgrade

# Upgrade macOs
# softwareupdate --all --install --force
