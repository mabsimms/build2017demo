#!/bin/bash

# Check for a valid settings
if [ ! -f ../deployment-settings.sh ]; then
    echo "Could not locate deployment-settings.sh file"
    exit
fi
source ../deployment-settings.sh

# Validate the parameters
echo "Creating k8 cluster with these settings:"
if [ -z ${DEMO_RESOURCE_GROUP+x} ]; then
    echo "Resource group is not set; exiting"
    exit
else
    echo "Resource group:  ${DEMO_RESOURCE_GROUP}"
fi

if [ -z ${DEMO_LOCATION+x} ]; then
    echo "Location is not set"
else
    echo "Location:        ${DEMO_LOCATION}"
fi

if [ -z ${DEMO_CLUSTER_NAME+x} ]; then
    echo "Cluster name is not set"
else
    echo "Cluster name:    ${DEMO_CLUSTER_NAME}"
fi

# Internal parameters
export AGENT_VM_SIZE=Standard_DS4_v2
export AGENT_COUNT=3

# Set up the resource group
echo "Creating resource group ${DEMO_RESOURCE_GROUP}"
az group create --name ${DEMO_RESOURCE_GROUP} --location ${DEMO_LOCATION}

echo "Creating Azure Key Vault"
# TODO

echo "Creating Azure Container Registry"
az acr create --resource-group ${DEMO_RESOURCE_GROUP} \
    --name ${DEMO_REGISTRY_NAME} --sku Basic --admin-enabled true
az acr login --name ${DEMO_REGISTRY_NAME}

echo "Creating Kubernetes cluster with name |${DEMO_CLUSTER_NAME}| with dns prefix |${DEMO_DNS_PREFIX}| in resource group |${DEMO_RESOURCE_GROUP}"
az acs create --orchestrator-type=kubernetes \
    --resource-group ${DEMO_RESOURCE_GROUP} \
    --name ${DEMO_CLUSTER_NAME} \
    --generate-ssh-keys \
    --agent-ports 80,443,8086,3000 \
    --agent-vm-size ${AGENT_VM_SIZE} \
    --agent-count ${AGENT_COUNT} \
    --dns-prefix ${DEMO_DNS_PREFIX} \
    --agent-storage-profile ManagedDisks \
    --master-storage-profile ManagedDisks 

echo "Installing kubernetes tools"
sudo az acs kubernetes install-cli 

echo "Retrieving Kubernetes credentials"
az acs kubernetes get-credentials \
    --resource-group=${DEMO_RESOURCE_GROUP} \
    --name=${DEMO_CLUSTER_NAME}

echo "Registering Azure Container registry with Kubernetes cluster ${DEMO_DNS_PREFIX}"
ACR_USERNAME=`az acr credential show -n ${DEMO_REGISTRY_NAME} -o json | jq '.username' | tr -d '"'`
ACR_PASSWORD=`az acr credential show -n ${DEMO_REGISTRY_NAME} -o json | jq '.passwords | .[0].value | tostring' | tr -d '"'`

docker login --username ${ACR_USERNAME} --password ${ACR_PASSWORD} ${DEMO_REGISTRY_LOGINSERVER}

kubectl create secret docker-registry ${DEMO_REGISTRY_NAME} \
    --docker-username=${ACR_USERNAME} \
    --docker-password=${ACR_PASSWORD} \
    --docker-email=masimms@microsoft.com 

kubectl get nodes
