#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- setup openai with rust"

cargo install chatgpt-cli
echo "" >> ~/.bashrc && echo "# openai" >> ~/.bashrc && echo "export OPENAI_API_KEY=$OPENAI_KEY" >> ~/.bashrc
source ~/.bashrc
