#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install postman"

pushd ~/Downloads
wget -cO- https://dl.pstmn.io/download/latest/linux_64 > postman.tar.gz
tar -xzvf postman.tar.gz
sudo mv Postman /opt
popd

pushd $2/data/files/postman
cp postman.desktop ~/.local/share/applications
sudo cp postman.svg /opt/Postman
popd
