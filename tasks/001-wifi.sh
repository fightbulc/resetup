#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- connecting to wifi $WIFI_ID"
#nmcli d wifi connect $WIFI_ID password $WIFI_PASSWORD
