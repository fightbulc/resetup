#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install rust"

echo "" >> ~/.bashrc
echo "# rust" >> ~/.bashrc
echo "" >> ~/.bashrc
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
source ~/.bashrc
