#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install docker"

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# UNINSTALL PRIOR PACKAGES
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

# ADD OFFICIAL KEYS
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# ADD REPOS TO SOURCES
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# IF YOU RUN A DEV VERSION YOU CAN ALSO HARDCODE THE RELEASE
#echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu lunar stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# UPDATE PACKAGES
sudo apt-get update

# INSTALL LATEST VERSION
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# POST INSTALLATION
echo "  Setting up docker group and permissions..."

# Create docker group if it doesn't exist
if ! getent group docker > /dev/null 2>&1; then
    sudo groupadd docker
    echo "  ✅ Docker group created"
else
    echo "  ✅ Docker group already exists"
fi

# Add user to docker group
sudo usermod -aG docker $USER
echo "  ✅ User added to docker group"

# Activate the changes to groups
newgrp docker

# VERIFY THAT DOCKER WORKS
echo "  Testing docker installation..."
if docker run hello-world > /dev/null 2>&1; then
    echo "  ✅ Docker is working correctly"
else
    echo "  ⚠️  Docker test failed - you may need to log out and back in"
    echo "     Or run: newgrp docker"
fi

