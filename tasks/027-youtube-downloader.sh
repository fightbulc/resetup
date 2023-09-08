#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

# https://github.com/yt-dlp

echo "- setup youtube downloader"

pushd $2/source
wget -cO - https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux > yt-dlp
sudo mv yt-dlp /usr/local/bin && sudo chmod +x /usr/local/bin/yt-dlp
