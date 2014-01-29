#!/bin/sh

reload_zsh_profile() {
  source ~/.zshenv
  source ~/.zshrc
}

sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install build-essential
sudo apt-get -y install bison
sudo apt-get -y install libreadline6-dev
sudo apt-get -y install curl
sudo apt-get -y install git-core
sudo apt-get -y install zlib1g-dev
sudo apt-get -y install libssl-dev
sudo apt-get -y install libyaml-dev
sudo apt-get -y install libsqlite3-dev
sudo apt-get -y install sqlite3
sudo apt-get -y install libxml2-dev
sudo apt-get -y install libxslt1-dev
sudo apt-get -y install autoconf
sudo apt-get -y install libncurses5-dev
sudo apt-get -y install vim
sudo apt-get -y install zsh

sudo chsh -s /bin/zsh shunirr

cd
git clone git://github.com/sstephenson/rbenv.git .rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

# dot-files
mkdir -p ~/dev
cd ~/dev
git clone git@github.com:shunirr/dot-files.git
cd dot-files
make
make install
reload_zsh_profile()
cd

rbenv install 2.1.0
rbenv install 2.0.0-p353
rbenv install 1.9.3-p484
