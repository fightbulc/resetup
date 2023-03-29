#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install telegram"

sudo apt install -y telegram-desktop 
