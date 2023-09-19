#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install deno"

curl -fsSL https://deno.land/x/install/install.sh | sh
echo "" >> ~/.bashrc
echo "# deno" >> ~/.bashrc
echo "" >> ~/.bashrc
echo 'export DENO_INSTALL="/home/fightbulc/.deno"' >> ~/.bashrc
echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.bashrc

# deno deploy
deno install -A --no-check -r -f https://deno.land/x/deploy/deployctl.ts
echo "" >> ~/.bashrc
echo "# deno deploy" >> ~/.bashrc
echo "export DENO_DEPLOY_TOKEN=$DENO_DEPLOY_ACCESSTOKEN" >> ~/.bashrc
