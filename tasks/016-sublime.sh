#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install sublime-merge/text"

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list 
sudo apt-get update && sudo apt-get install -y sublime-merge sublime-text 

echo "- add licenses"
cp $2/data/files/sublime/text.license ~/.config/sublime-text/Local/License.sublime_license
cp $2/data/files/sublime/merge.license ~/.config/sublime-merge/Local/License.sublime_license