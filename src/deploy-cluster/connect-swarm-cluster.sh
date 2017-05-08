#!/bin/bash

# Ports for Swarm management
LOCAL_PORT=2375
REMOTE_PORT=2375

# Other settings - ensure that you have source'ed the
# environment-dnsprefix.sh file
USERNAME=${DEMO_USERNAME}
REGION=${DEMO_LOCATION}
PATH_TO_PRIVATE_KEY=${DEMO_SSH_PUBLIC_KEY_FILE}

echo "Looking up ACS deployment name"
ACS_NAME=`az acs list --resource-group ${DEMO_RESOURCE_GROUP} | jq .[].name | sed 's/\"//g'`

echo "Looking up management FQDN"
MGMT_FQDN=`az acs show --name ${ACS_NAME} --resource-group ${DEMO_RESOURCE_GROUP} | \
    jq .masterProfile.fqdn | sed 's/\"//g'`

echo "Connecting tunnel to management endpoint $FQDN"
ssh -fNL ${LOCAL_PORT}:localhost:${REMOTE_PORT} -p 2200 ${USERNAME}@${MGMT_FQDN} \
    -i ${PATH_TO_PRIVATE_KEY}
export DOCKER_HOST=:2375

# Get the FQDN of the agent public iP
echo "Looking up agent public ip name"
AGENT_PIP_NAME=`az network public-ip list --resource-group ${DEMO_RESOURCE_GROUP} \
    --output table | grep agents | tr -s ' ' | cut -d' ' -f5`
echo "Looking up agent public ip fqdn"
AGENT_FQDN=`az network public-ip show --name ${AGENT_PIP_NAME} \
    --resource-group ${DEMO_RESOURCE_GROUP} | jq .dnsSettings.fqdn | sed 's/\"//g'`


# Add these settings to the environment file
echo "Adding connection values to environment settings"
echo "export DEMO_ACS_NAME=${ACS_NAME}" >> ${DEMO_ENV_PATH} 
echo "export DEMO_MGMT_FQDN=${MGMT_FQDN}" >> ${DEMO_ENV_PATH} 
echo "export DEMO_AGENT_FQDN=${AGENT_FQDN}" >> ${DEMO_ENV_PATH} 
echo "export DOCKER_HOST=:2375" >>  ${DEMO_ENV_PATH} 
echo "alias connect-swarm='ssh -fNL ${LOCAL_PORT}:localhost:${REMOTE_PORT} -p 2200 ${USERNAME}@${MGMT_FQDN} -i ${PATH_TO_PRIVATE_KEY}'" >> ${DEMO_ENV_PATH}

source ${DEMO_ENV_PATH} 