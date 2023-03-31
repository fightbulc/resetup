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

sudo apt update

sudo apt -y install\
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
	jq
