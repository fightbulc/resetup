#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install base"

cat $2/data/files/header.bash >> ~/.bashrc

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

sudo apt update

sudo apt -y install\
	vim\
	wget\
	gpg\
	curl\
	build-essential\
	git\
	default-jre\
	libfuse2\
	rclone\
	libminizip1\
	gnome-shell-extension-manager\
	gnome-tweaks\
	ntfs-3g\
	jq\
	libssl-dev\
	openssl\
	pkg-config

#
# add /usr/local/bin to PATH
#

echo "" >> ~/.bashrc && echo "# ADD /usr/local/bin TO PATH" >> ~/.bashrc && echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc

#
# fixing chrome freeze when accessing file system
#

sudo apt -y install xdg-desktop-portal-gnome

#
# sourcing
#

source ~/.bashrc
