#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install ffmpeg"

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

sudo apt update
sudo apt -y install ffmpeg

# Verify installation
ffmpeg -version