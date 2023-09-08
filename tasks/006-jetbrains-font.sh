#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- jetbrains font"

pushd $2/source
wget -cO - "https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip" > jetbrains-mono.zip
unzip jetbrains-mono.zip -d mono && rm jetbrains-mono.zip 
mkdir ~/.fonts && mv mono/fonts/* ~/.fonts/ && rm -rf mono
PROIFLE_ID=:$(gsettings get org.gnome.Terminal.ProfilesList default | sed "s:'*::g")
dconf write /org/gnome/terminal/legacy/profiles:/$PROIFLE_ID/font "'JetBrains Mono 14'"
popd
