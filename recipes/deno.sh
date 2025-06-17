#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install deno"

# Install deno non-interactively
curl -fsSL https://deno.land/install.sh | sh -s -- -y

# Add deno to PATH using generic home directory
echo "" >> ~/.bashrc
echo "# deno" >> ~/.bashrc
echo "" >> ~/.bashrc
echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.bashrc
echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.bashrc

# deno deploy
source ~/.bashrc
deno install -A --no-check -r -f https://deno.land/x/deploy/deployctl.ts

# Add deno deploy token if provided
if [ ! -z "$DENO_DEPLOY_ACCESSTOKEN" ]; then
    echo "" >> ~/.bashrc
    echo "# deno deploy" >> ~/.bashrc
    echo "export DENO_DEPLOY_TOKEN=$DENO_DEPLOY_ACCESSTOKEN" >> ~/.bashrc
    echo "  Deno Deploy token configured"
else
    echo "  Deno Deploy token not found in config - skipping token setup"
fi

# Set up bash completions
echo "  Setting up bash completions..."
sudo mkdir -p /usr/local/etc/bash_completion.d
sudo deno completions bash > /usr/local/etc/bash_completion.d/deno.bash
echo "" >> ~/.bashrc
echo "# deno bash completions" >> ~/.bashrc
echo "[ -f /usr/local/etc/bash_completion.d/deno.bash ] && source /usr/local/etc/bash_completion.d/deno.bash" >> ~/.bashrc

echo "  ✅ Deno installation completed with bash completions"
