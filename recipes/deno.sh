#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install deno"

# Install deno with bash shell selection
echo "bash" | curl -fsSL https://deno.land/x/install/install.sh | sh

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

echo "  ✅ Deno installation completed"
