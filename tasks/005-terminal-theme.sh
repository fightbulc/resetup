#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- Dracula terminal theme"

pushd ~/setup
sudo apt-get install -y dconf-cli
PROIFLE_ID=:$(gsettings get org.gnome.Terminal.ProfilesList default | sed "s:'*::g")
git clone https://github.com/dracula/gnome-terminal && cd gnome-terminal
./install.sh --scheme Dracula --profile $PROIFLE_ID --install-dircolors
cd .. && rm -rf gnome-terminal
echo "" >> ~/.bashrc && echo 'eval `dircolors /home/fightbulc/.dir_colors/dircolors`' >> ~/.bashrc
source ~/.bashrc
popd
