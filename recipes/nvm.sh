#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- nvm"

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash 

# Load nvm for current session and install node versions
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install 19
nvm alias default 19
nvm install node

# Add custom nvm configuration if it exists
if [ -f "$2/data/files/.nvm.bash" ]; then
    echo "" >> ~/.bashrc
    cat $2/data/files/.nvm.bash >> ~/.bashrc
fi
