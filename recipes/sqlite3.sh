#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install sqlite3"

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# Update package list
sudo apt update

# Install SQLite3 and development libraries
sudo apt -y install\
	sqlite3\
	libsqlite3-dev\
	sqlite3-doc

# Install useful SQLite tools
sudo apt -y install\
	sqlitebrowser

echo "sqlite3 installed successfully"

# Show installed version
sqlite3 --version