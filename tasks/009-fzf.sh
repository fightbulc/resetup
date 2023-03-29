#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- fzf"

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 
echo "" >> ~/.bashrc
echo "# fzf" >> ~/.bashrc
echo "" >> ~/.bashrc
~/.fzf/install --all 
