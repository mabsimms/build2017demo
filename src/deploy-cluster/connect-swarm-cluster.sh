#!/bin/bash

# Ports for Swarm management
LOCAL_PORT=2375
REMOTE_PORT=2375

# Other settings - ensure that you have source'ed the
# environment-dnsprefix.sh file
USERNAME=${DEMO_USERNAME}
REGION=${DEMO_LOCATION}
PATH_TO_PRIVATE_KEY=${DEMO_SSH_PUBLIC_KEY_FILE}

# Get the network configuration for this cluster
MGMT_PIP_NAME=`az network public-ip list --resource-group masbld-rg --output table | grep mgmt | tr -s ' ' | cut -d ' ' -f5`
MGMT_FQDN=`az network public-ip show --name ${MGMT_PIP_NAME} \
    --resource-group ${DEMO_RESOURCE_GROUP} | jq .dnsSettings.fqdn | sed 's/\"//g'`
echo "Management public ip name ${MGMT_PIP_NAME} fqdn is ${MGMT_FQDN}"

AGENT_PIP_NAME=`az network public-ip list --resource-group masbld-rg --output table | grep agent | tr -s ' ' | cut -d ' ' -f5`
AGENT_FQDN=`az network public-ip show --name ${AGENT_PIP_NAME} \
    --resource-group ${DEMO_RESOURCE_GROUP} | jq .dnsSettings.fqdn | sed 's/\"//g'`
echo "Agent public ip name ${AGENT_PIP_NAME} fqdn is ${AGENT_FQDN}"

echo "Connecting tunnel to management endpoint $FQDN"
echo ssh -fNL ${LOCAL_PORT}:localhost:${REMOTE_PORT} -p 2200 ${USERNAME}@${MGMT_FQDN} \
    -i ${PATH_TO_PRIVATE_KEY}
ssh -fNL ${LOCAL_PORT}:localhost:${REMOTE_PORT} -p 2200 ${USERNAME}@${MGMT_FQDN} \
    -i ${PATH_TO_PRIVATE_KEY}
export DOCKER_HOST=:2375

# Add these settings to the environment file
echo "Adding connection values to environment settings"
echo "export DEMO_ACS_NAME=${ACS_NAME}" >> ${DEMO_ENV_PATH} 
echo "export DEMO_MGMT_FQDN=${MGMT_FQDN}" >> ${DEMO_ENV_PATH} 
echo "export DEMO_AGENT_FQDN=${AGENT_FQDN}" >> ${DEMO_ENV_PATH} 
echo "export DOCKER_HOST=:2375" >>  ${DEMO_ENV_PATH} 
echo "alias connect-swarm='ssh -fNL ${LOCAL_PORT}:localhost:${REMOTE_PORT} -p 2200 ${USERNAME}@${MGMT_FQDN} -i ${PATH_TO_PRIVATE_KEY}'" >> ${DEMO_ENV_PATH}

source ${DEMO_ENV_PATH} 
