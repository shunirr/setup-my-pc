#!/bin/bash

copy_local_bin() {
  if [ ! -d "/usr/local/bin" ]; then
    sudo mkdir -p "/usr/local/bin"
  fi
  if [ ! -f "/usr/local/bin/$(basename \"$1\")" ]; then
    sudo cp "$1" "/usr/local/bin/$(basename $1)"
  fi
}

git_clone() {
  CLONE_PATH=$1
  GIT_URL=$2
  if [ ! -d $CLONE_PATH ]; then
    yes | git clone $GIT_URL $CLONE_PATH
  fi
}

sudo add-apt-repository ppa:tualatrix/ppa
sudo add-apt-repository ppa:indicator-multiload/stable-dialy

sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install \
  build-essential \
  libgtk-3-dev \
  bison \
  libreadline6-dev \
  curl \
  git-core \
  zlib1g-dev \
  libssl-dev \
  libyaml-dev \
  libsqlite3-dev \
  sqlite3 \
  libxml2-dev \
  libxslt1-dev \
  autoconf \
  libncurses5-dev \
  vim \
  zsh \
  ubuntu-tweak \
  gnome-tweak-tool \
  unity-tweak-tool \
  xbacklight \
  ibus-skk \
  vlc \
  gdebi \
  ubuntu-restricted-extras \
  openjdk-7-jdk \
  indicator-multiload


sudo apt-get remove \
  unity-webapps-common \
  xul-ext-websites-integration \
  ubuntuone-client \
  python-ubuntuone-client \
  python-ubuntuone-storageprotocol \
  unity-lens-shopping

env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update

sudo chsh -s /bin/zsh shunirr

pushd ~/
  git_clone ".rbenv"                    "https://github.com/sstephenson/rbenv.git"
  git_clone ".rbenv/plugins/ruby-build" "https://github.com/sstephenson/ruby-build.git"
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  
  # dot-files
  [[ -d ~/dev ]] || mkdir -p ~/dev
  pushd ~/dev
    git_clone "dot-files" "git@github.com:shunirr/dot-files.git"
    pushd dot-files
      make
      make install
    popd
  popd
popd

rbenv install 2.1.0

copy_local_bin "./ubuntu-vaio-pro/cpufreq"
copy_local_bin "./ubuntu-vaio-pro/powersave"
