#!/bin/bash

# Ports for Swarm management
LOCAL_PORT=2375
REMOTE_PORT=2375
USERNAME=masimms
REGION=eastus2
PATH_TO_PRIVATE_KEY=~/swarm_rsa

FQDN=`az acs show --name containerservice-mas-bld-rg --resource-group mas-bld-rg | \
    jq .masterProfile.fqdn | sed 's/\"//g'`

echo "Connecting tunnel to management endpoint $FQDN"
ssh -fNL ${LOCAL_PORT}:localhost:${REMOTE_PORT} -p 2200 ${USERNAME}@${FQDN} \
    -i ${PATH_TO_PRIVATE_KEY}
export DOCKER_HOST=:2375
