#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- nvm"

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash 
source ~/.bashrc

nvm install 19
nvm alias default 19

echo "" >> ~/.bashrc
cat $2/data/files/.nvm.bash >> ~/.bashrc
source ~/.bashrc
