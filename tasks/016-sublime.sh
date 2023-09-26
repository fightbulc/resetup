#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- setup sublime"

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list 
sudo apt-get update

echo "- install sublime-merge"
sudo apt-get install -y sublime-merge
echo "- adding license"
cp $2/data/files/sublime/merge.license ~/.config/sublime-merge/Local/License.sublime_license

# echo "- install sublime-text"
# sudo apt-get install -y sublime-text
# echo "- adding license"
# cp $2/data/files/sublime/text.license ~/.config/sublime-text/Local/License.sublime_license